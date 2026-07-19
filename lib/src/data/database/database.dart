import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// A study project — the top of the Chronus hierarchy. A project groups the
/// studies that are compared against one another (comparison is scoped to a
/// single project in v1).
///
/// Primary keys are string UUIDs so ids stay stable across the `.chronus`
/// backup/restore bundle and the iOS -> Windows migration path (no autoincrement
/// collisions when merging devices).
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Projects])
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database. Pass an explicit [executor] (e.g.
  /// `NativeDatabase.memory()`) in tests to run against an in-memory database.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openOnDevice());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openOnDevice() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'chronus.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
