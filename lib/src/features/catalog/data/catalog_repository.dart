import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';

/// Data access for the reusable operation [CatalogOperation]s and their
/// classification [OperationSubtype]s.
class CatalogRepository {
  CatalogRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<CatalogOperation>> watchAll() {
    return (_db.select(_db.catalogOperations)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Stream<CatalogOperation> watchById(String id) {
    return (_db.select(_db.catalogOperations)..where((t) => t.id.equals(id)))
        .watchSingle();
  }

  Future<CatalogOperation> create({
    required String name,
    required OperationCategory category,
    String? subtypeId,
    int? referenceStandardMs,
  }) {
    final now = DateTime.now();
    return _db.into(_db.catalogOperations).insertReturning(
          CatalogOperationsCompanion.insert(
            id: _uuid.v4(),
            name: name,
            category: category,
            subtypeId: Value(subtypeId),
            referenceStandardMs: Value(referenceStandardMs),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> update({
    required String id,
    required String name,
    required OperationCategory category,
    String? subtypeId,
    int? referenceStandardMs,
  }) {
    return (_db.update(_db.catalogOperations)..where((t) => t.id.equals(id)))
        .write(
      CatalogOperationsCompanion(
        name: Value(name),
        category: Value(category),
        subtypeId: Value(subtypeId),
        referenceStandardMs: Value(referenceStandardMs),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.catalogOperations)..where((t) => t.id.equals(id)))
        .go();
  }

  // --- Subtypes -----------------------------------------------------------

  Stream<List<OperationSubtype>> watchSubtypes() {
    return (_db.select(_db.operationSubtypes)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isBuiltIn),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<OperationSubtype> createSubtype({
    required OperationCategory category,
    required String name,
  }) {
    return _db.into(_db.operationSubtypes).insertReturning(
          OperationSubtypesCompanion.insert(
            id: _uuid.v4(),
            category: category,
            name: name,
            isBuiltIn: const Value(false),
            createdAt: DateTime.now(),
          ),
        );
  }
}
