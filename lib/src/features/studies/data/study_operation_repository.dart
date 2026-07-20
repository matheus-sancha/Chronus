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

  Future<void> remove(String id) {
    return (_db.delete(_db.studyOperations)..where((t) => t.id.equals(id))).go();
  }
}
