import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';

/// Templates = reusable ordered CATALOG REFERENCES + default study settings.
/// No measured data. Instantiating snapshots the referenced catalog operations
/// into a new study; saving a study as a template keeps its catalog-backed
/// operations + settings (custom, non-catalog operations are not included).
class TemplateRepository {
  TemplateRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Template>> watchAll() {
    return (_db.select(_db.templates)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Stream<Template> watchById(String id) {
    return (_db.select(_db.templates)..where((t) => t.id.equals(id)))
        .watchSingle();
  }

  Stream<List<TemplateOperation>> watchOperations(String templateId) {
    return (_db.select(_db.templateOperations)
          ..where((t) => t.templateId.equals(templateId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  Future<Template> create({
    required String name,
    required StudyType defaultStudyType,
    double defaultAllowancePercent = 0,
  }) {
    final now = DateTime.now();
    return _db.into(_db.templates).insertReturning(
          TemplatesCompanion.insert(
            id: _uuid.v4(),
            name: name,
            defaultStudyType: defaultStudyType,
            defaultAllowancePercent: Value(defaultAllowancePercent),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> update({
    required String id,
    required String name,
    required StudyType defaultStudyType,
    required double defaultAllowancePercent,
  }) {
    return (_db.update(_db.templates)..where((t) => t.id.equals(id))).write(
      TemplatesCompanion(
        name: Value(name),
        defaultStudyType: Value(defaultStudyType),
        defaultAllowancePercent: Value(defaultAllowancePercent),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.templates)..where((t) => t.id.equals(id))).go();
  }

  Future<double> _nextOrder(String templateId) async {
    final existing = await (_db.select(_db.templateOperations)
          ..where((t) => t.templateId.equals(templateId)))
        .get();
    return existing.isEmpty
        ? 1.0
        : existing.map((e) => e.orderIndex).reduce(max) + 1;
  }

  /// Adds a catalog operation, snapshotting its fields (+ keeping the link).
  Future<void> addFromCatalog({
    required String templateId,
    required CatalogOperation operation,
  }) async {
    await _db.into(_db.templateOperations).insert(
          TemplateOperationsCompanion.insert(
            id: _uuid.v4(),
            templateId: templateId,
            catalogOperationId: Value(operation.id),
            orderIndex: await _nextOrder(templateId),
            name: operation.name,
            category: operation.category,
            subtypeId: Value(operation.subtypeId),
            referenceStandardMs: Value(operation.referenceStandardMs),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Adds a template-local operation with no catalog link.
  Future<void> addCustom({
    required String templateId,
    required String name,
    required OperationCategory category,
    String? subtypeId,
    int? referenceStandardMs,
  }) async {
    await _db.into(_db.templateOperations).insert(
          TemplateOperationsCompanion.insert(
            id: _uuid.v4(),
            templateId: templateId,
            orderIndex: await _nextOrder(templateId),
            name: name,
            category: category,
            subtypeId: Value(subtypeId),
            referenceStandardMs: Value(referenceStandardMs),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> reorderOperations(List<String> orderedIds) async {
    await _db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          _db.templateOperations,
          TemplateOperationsCompanion(orderIndex: Value((i + 1).toDouble())),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<void> removeOperation(String id) {
    return (_db.delete(_db.templateOperations)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Creates a study in [projectId] from the template, snapshotting each
  /// referenced catalog operation into the study's sequence.
  Future<Study> instantiate({
    required String templateId,
    required String projectId,
    required String name,
    String? analyst,
  }) {
    return _db.transaction(() async {
      final template = await (_db.select(_db.templates)
            ..where((t) => t.id.equals(templateId)))
          .getSingle();
      final now = DateTime.now();
      final studyId = _uuid.v4();
      final study = await _db.into(_db.studies).insertReturning(
            StudiesCompanion.insert(
              id: studyId,
              projectId: projectId,
              type: template.defaultStudyType,
              name: name,
              performedAt: now,
              analyst: Value(analyst),
              allowancePercent: Value(template.defaultAllowancePercent),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final templateOps = await (_db.select(_db.templateOperations)
            ..where((t) => t.templateId.equals(templateId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
      var order = 1.0;
      for (final top in templateOps) {
        await _db.into(_db.studyOperations).insert(
              StudyOperationsCompanion.insert(
                id: _uuid.v4(),
                studyId: studyId,
                catalogOperationId: Value(top.catalogOperationId),
                orderIndex: order++,
                name: top.name,
                category: top.category,
                subtypeId: Value(top.subtypeId),
                referenceStandardMs: Value(top.referenceStandardMs),
                createdAt: now,
              ),
            );
      }
      return study;
    });
  }

  /// Creates a template from a study: its settings + its full operation
  /// sequence (catalog-backed and custom alike, snapshotted).
  Future<Template> saveStudyAsTemplate({
    required String studyId,
    required String name,
  }) {
    return _db.transaction(() async {
      final study = await (_db.select(_db.studies)
            ..where((t) => t.id.equals(studyId)))
          .getSingle();
      final template = await create(
        name: name,
        defaultStudyType: study.type,
        defaultAllowancePercent: study.allowancePercent,
      );
      final ops = await (_db.select(_db.studyOperations)
            ..where((t) => t.studyId.equals(studyId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
      var order = 1.0;
      for (final op in ops) {
        await _db.into(_db.templateOperations).insert(
              TemplateOperationsCompanion.insert(
                id: _uuid.v4(),
                templateId: template.id,
                catalogOperationId: Value(op.catalogOperationId),
                orderIndex: order++,
                name: op.name,
                category: op.category,
                subtypeId: Value(op.subtypeId),
                referenceStandardMs: Value(op.referenceStandardMs),
                createdAt: DateTime.now(),
              ),
            );
      }
      return template;
    });
  }
}
