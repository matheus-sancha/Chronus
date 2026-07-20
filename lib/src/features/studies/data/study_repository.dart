import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';

/// Data access for [Study] rows. The only seam onto Drift for studies.
class StudyRepository {
  StudyRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Studies in a project, most recent first.
  Stream<List<Study>> watchByProject(String projectId) {
    return (_db.select(_db.studies)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.desc(t.performedAt)]))
        .watch();
  }

  Stream<Study> watchById(String id) {
    return (_db.select(_db.studies)..where((t) => t.id.equals(id)))
        .watchSingle();
  }

  Future<Study> create({
    required String projectId,
    required String name,
    required StudyType type,
    String? analyst,
  }) {
    final now = DateTime.now();
    return _db.into(_db.studies).insertReturning(
          StudiesCompanion.insert(
            id: _uuid.v4(),
            projectId: projectId,
            type: type,
            name: name,
            performedAt: now,
            analyst: Value(analyst),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Applies [changes] to the study, stamping `updatedAt`. The caller builds the
  /// companion with whichever header fields it is editing.
  Future<void> update(String id, StudiesCompanion changes) {
    return (_db.update(_db.studies)..where((t) => t.id.equals(id)))
        .write(changes.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.studies)..where((t) => t.id.equals(id))).go();
  }
}
