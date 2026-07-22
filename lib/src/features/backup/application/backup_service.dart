import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../../data/database/database.dart';
import '../data/backup_bundle.dart';

/// Creates and restores `.chronus` bundles — the app's only insurance against
/// device loss, and the iOS↔Windows migration path (DESIGN.md §2).
///
/// The base directory is injected so tests can point at a temp dir.
class BackupService {
  BackupService(this._db, this._appDir);

  final AppDatabase _db;
  final Future<Directory> Function() _appDir;

  /// Packs the whole app into bundle bytes.
  Future<Uint8List> export({DateTime? createdAt}) async {
    final base = await _appDir();
    final staging = await Directory(p.join(base.path, '.backup-staging'))
        .create(recursive: true);
    try {
      final snapshot = File(p.join(staging.path, 'snapshot.sqlite'));
      if (snapshot.existsSync()) snapshot.deleteSync();

      // VACUUM INTO, not a file copy: it takes a transactionally consistent
      // snapshot of the live database without closing it, and folds in any
      // un-checkpointed WAL content. Copying chronus.sqlite could capture a
      // torn write or silently drop recent changes.
      await _db.customStatement('VACUUM INTO ?', [snapshot.path]);

      return writeBundle(
        databaseSnapshot: snapshot,
        media: _collectMedia(base),
        schemaVersion: _db.schemaVersion,
        createdAt: createdAt,
      );
    } finally {
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }

  /// Everything under `media/`, keyed by the relative path the database stores.
  ///
  /// Walks the directory rather than the attachment rows, so a bundle can never
  /// restore a database that references a file the bundle omitted.
  List<({String relativePath, File file})> _collectMedia(Directory base) {
    final dir = Directory(p.join(base.path, 'media'));
    if (!dir.existsSync()) return const [];
    return [
      for (final entity in dir.listSync(recursive: true))
        if (entity is File)
          (
            relativePath:
                'media/${p.relative(entity.path, from: dir.path).replaceAll(r'\', '/')}',
            file: entity,
          ),
    ];
  }

  /// Replaces all app data with the contents of [bytes].
  ///
  /// Destructive and deliberately total — this is "restore from backup", not a
  /// merge. Callers must confirm with the user first.
  ///
  /// Rather than swapping the database file underneath a live connection, the
  /// bundle's tables are copied into the running database in one transaction.
  /// That keeps every existing connection, provider and stream valid, so no
  /// app restart is needed and there is no window where the file on disk and
  /// the open handle disagree.
  Future<BackupManifest> import(Uint8List bytes) async {
    final base = await _appDir();
    final staging = Directory(p.join(base.path, '.restore-staging'));
    if (staging.existsSync()) staging.deleteSync(recursive: true);

    try {
      // Validates before touching anything: a rejected bundle leaves the app
      // exactly as it was.
      final bundle = unpackBundle(
        bytes: bytes,
        destination: staging,
        supportedSchemaVersion: _db.schemaVersion,
      );

      await _migrateToCurrentSchema(bundle.database);
      await _copyTablesFrom(bundle.database);
      await _replaceMedia(base, bundle.mediaDirectory);

      // Raw statements bypass drift's update tracking, so every stream query
      // would keep serving pre-restore data until something else wrote.
      _db.notifyUpdates({
        for (final table in _db.allTables)
          TableUpdate(table.actualTableName, kind: UpdateKind.update),
      });

      return bundle.manifest;
    } finally {
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }

  /// Opens the bundle's database on its own so Drift runs any pending
  /// migrations, bringing an older bundle up to the current schema before its
  /// rows are copied. Without this, column lists would not line up.
  ///
  /// NOTE: currently unreachable in practice — bundles were introduced at
  /// schema 3, so no bundle with an older schema can exist. It first matters
  /// when the schema next moves; that is the point to add a test restoring a
  /// real schema-3 bundle into a schema-4 build.
  Future<void> _migrateToCurrentSchema(File database) async {
    // Drift warns when a second AppDatabase is constructed, because sharing one
    // QueryExecutor would race. This one has its own executor over a different
    // file, so the warning does not apply — silence it just for this open.
    final warned = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final migrated = AppDatabase(NativeDatabase(database));
    try {
      // Opening is lazy; this forces the migration to actually run.
      await migrated.customSelect('SELECT 1').get();
    } finally {
      await migrated.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = warned;
    }
  }

  Future<void> _copyTablesFrom(File database) async {
    // ATTACH and PRAGMA foreign_keys are both illegal inside a transaction, so
    // they bracket it rather than sit within it.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    await _db.customStatement("ATTACH DATABASE ? AS backup", [database.path]);
    try {
      await _db.transaction(() async {
        for (final table in _db.allTables) {
          final name = table.actualTableName;
          // Columns listed explicitly rather than `SELECT *`: a table rebuilt
          // by a migration can end up with a different column order than a
          // freshly created one, and positional copying would silently
          // scramble the values.
          final columns = table.$columns.map((c) => c.name).join(', ');
          await _db.customStatement('DELETE FROM main.$name');
          await _db.customStatement(
            'INSERT INTO main.$name ($columns) SELECT $columns FROM backup.$name',
          );
        }
      });
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _replaceMedia(Directory base, Directory source) async {
    final target = Directory(p.join(base.path, 'media'));
    if (target.existsSync()) target.deleteSync(recursive: true);
    target.createSync(recursive: true);

    if (!source.existsSync()) return;
    for (final entity in source.listSync(recursive: true)) {
      if (entity is! File) continue;
      final destination =
          File(p.join(target.path, p.relative(entity.path, from: source.path)));
      destination.parent.createSync(recursive: true);
      entity.copySync(destination.path);
    }
  }
}
