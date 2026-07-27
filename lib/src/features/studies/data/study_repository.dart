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

  /// Creates the study **and its first pass**, in one transaction.
  ///
  /// A study always has at least one [Observation] (DESIGN.md §11.1): a Time
  /// Study has exactly this one forever, a Sampling Study grows more. Holding
  /// that invariant from creation is what lets the workspace, the report and the
  /// export drop their "no observation yet" branches — and a study whose pass
  /// creation failed would be a study that cannot be timed, so the two rows are
  /// written together or not at all.
  Future<Study> create({
    required String projectId,
    required String name,
    required StudyType type,
    String? analyst,
  }) {
    return _db.transaction(() async {
      final now = DateTime.now();
      final study = await _db.into(_db.studies).insertReturning(
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
      await _db.into(_db.observations).insert(
            ObservationsCompanion.insert(
              id: _uuid.v4(),
              studyId: study.id,
              sequenceIndex: 0,
              performedAt: now,
              createdAt: now,
            ),
          );
      return study;
    });
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
