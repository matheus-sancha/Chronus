import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';

/// Manages a study's ordered operation sequence ([StudyOperation]s). Adding from
/// the catalog SNAPSHOTS the catalog fields (name/category/subtype/reference
/// standard) and keeps a hidden [catalogOperationId] link — so later catalog
/// edits never mutate this study's history.
class StudyOperationRepository {
  StudyOperationRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<StudyOperation>> watchByStudy(String studyId) {
    return (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.equals(studyId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  Future<void> addFromCatalog({
    required String studyId,
    required CatalogOperation operation,
  }) async {
    final existing = await (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.equals(studyId)))
        .get();
    final nextOrder = existing.isEmpty
        ? 1.0
        : existing.map((e) => e.orderIndex).reduce(max) + 1;

    await _db.into(_db.studyOperations).insert(
          StudyOperationsCompanion.insert(
            id: _uuid.v4(),
            studyId: studyId,
            catalogOperationId: Value(operation.id),
            orderIndex: nextOrder,
            name: operation.name,
            category: operation.category,
            subtypeId: Value(operation.subtypeId),
            referenceStandardMs: Value(operation.referenceStandardMs),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Adds a study-local operation not backed by the catalog
  /// ([catalogOperationId] stays null).
  Future<void> addCustom({
    required String studyId,
    required String name,
    required OperationCategory category,
    String? subtypeId,
    int? referenceStandardMs,
  }) async {
    final existing = await (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.equals(studyId)))
        .get();
    final nextOrder = existing.isEmpty
        ? 1.0
        : existing.map((e) => e.orderIndex).reduce(max) + 1;

    await _db.into(_db.studyOperations).insert(
          StudyOperationsCompanion.insert(
            id: _uuid.v4(),
            studyId: studyId,
            orderIndex: nextOrder,
            name: name,
            category: category,
            subtypeId: Value(subtypeId),
            referenceStandardMs: Value(referenceStandardMs),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Inserts an unplanned operation immediately after [afterStudyOperationId],
  /// using a fractional [orderIndex] so the rest of the sequence is undisturbed.
  /// Used by the pause → "log an interruption" flow; returns the new row so the
  /// caller can start timing it. [catalogOperationId] stays null (study-local).
  Future<StudyOperation> insertUnplannedAfter({
    required String studyId,
    required String afterStudyOperationId,
    required String name,
    required OperationCategory category,
    String? subtypeId,
  }) async {
    final ops = await (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.equals(studyId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final idx = ops.indexWhere((o) => o.id == afterStudyOperationId);
    final current = idx >= 0
        ? ops[idx].orderIndex
        : (ops.isEmpty ? 0.0 : ops.last.orderIndex);
    double? next;
    for (final o in ops) {
      if (o.orderIndex > current && (next == null || o.orderIndex < next)) {
        next = o.orderIndex;
      }
    }
    final order = next == null ? current + 0.5 : (current + next) / 2;

    return _db.into(_db.studyOperations).insertReturning(
          StudyOperationsCompanion.insert(
            id: _uuid.v4(),
            studyId: studyId,
            orderIndex: order,
            name: name,
            category: category,
            subtypeId: Value(subtypeId),
            isUnplanned: const Value(true),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Rewrites the order to match [orderedIds] (positions 1..N).
  Future<void> reorder(List<String> orderedIds) async {
    await _db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          _db.studyOperations,
          StudyOperationsCompanion(orderIndex: Value((i + 1).toDouble())),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// Edits one operation's snapshot fields (name / type / subtype / expected
  /// time). The hidden catalog link and order are left untouched.
  Future<void> update({
    required String id,
    required String name,
    required OperationCategory category,
    String? subtypeId,
    int? referenceStandardMs,
  }) {
    return (_db.update(_db.studyOperations)..where((t) => t.id.equals(id)))
        .write(
      StudyOperationsCompanion(
        name: Value(name),
        category: Value(category),
        subtypeId: Value(subtypeId),
        referenceStandardMs: Value(referenceStandardMs),
      ),
    );
  }

  /// Copies an operation in place, just after the original (fractional order),
  /// with no timing. The copy keeps the catalog link and unplanned flag.
  Future<void> duplicate(String id) async {
    final src = await (_db.select(_db.studyOperations)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (src == null) return;
    final all = await (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.equals(src.studyId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    double? next;
    for (final o in all) {
      if (o.orderIndex > src.orderIndex &&
          (next == null || o.orderIndex < next)) {
        next = o.orderIndex;
      }
    }
    final order = next == null ? src.orderIndex + 1 : (src.orderIndex + next) / 2;
    await _db.into(_db.studyOperations).insert(
          StudyOperationsCompanion.insert(
            id: _uuid.v4(),
            studyId: src.studyId,
            catalogOperationId: Value(src.catalogOperationId),
            orderIndex: order,
            name: src.name,
            category: src.category,
            subtypeId: Value(src.subtypeId),
            referenceStandardMs: Value(src.referenceStandardMs),
            isUnplanned: Value(src.isUnplanned),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> remove(String id) {
    return (_db.delete(_db.studyOperations)..where((t) => t.id.equals(id))).go();
  }
}
