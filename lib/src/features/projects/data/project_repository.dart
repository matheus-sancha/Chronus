import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';

/// Data access for [Project] rows. The single seam between Drift and the rest
/// of the app: notifiers and UI depend on this, never on the database directly.
class ProjectRepository {
  ProjectRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Watches all projects, most-recently-updated first. Emits a new list
  /// whenever the underlying table changes.
  Stream<List<Project>> watchAll() {
    return (_db.select(_db.projects)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<Project> create({required String name, String? notes}) {
    final now = DateTime.now();
    return _db.into(_db.projects).insertReturning(
          ProjectsCompanion.insert(
            id: _uuid.v4(),
            name: name,
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();
  }
}
