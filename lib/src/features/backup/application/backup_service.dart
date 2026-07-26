import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../../data/database/database.dart';
import '../data/backup_bundle.dart';

/// Two safety nets, aimed at two different failures.
///
/// * **`.chronus` bundles** (manual, user-driven) — insurance against device
///   loss, and the iOS↔Windows migration path (DESIGN.md §2). Everything: rows
///   and photos.
/// * **Automatic snapshots** (silent, database-only) — insurance against *us*: a
///   bug or a bad migration eating rows. See [snapshotIfDue] (DESIGN.md §10).
///
/// The split exists because the two failures need different things. Device loss
/// needs the photos and a copy that leaves the machine; our own bugs need
/// something frequent, free and unattended, and photos are not at risk from
/// them.
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

  // --- automatic snapshots --------------------------------------------------

  /// Directory holding automatic snapshots, beside the live database.
  static const snapshotsDirName = 'snapshots';

  /// How many to keep. Three spans a long weekend, which is the realistic gap
  /// between "something went wrong" and anyone noticing.
  static const snapshotsToKeep = 3;

  /// Minimum age of the newest snapshot before another is taken.
  static const snapshotInterval = Duration(days: 1);

  /// Takes a snapshot if the newest one is older than [snapshotInterval], then
  /// prunes to [snapshotsToKeep]. Returns the file written, or null if one was
  /// not due.
  ///
  /// **Database only, no media.** Photos are immutable once written and no
  /// migration touches them, so the database is the only thing a bug of ours can
  /// corrupt — and copying the photo library three times over would cost orders
  /// of magnitude more disk to protect something that is not at risk. Device
  /// loss is what the manual `.chronus` bundle is for (DESIGN.md §2); this is
  /// insurance against *us*.
  ///
  /// Silent by design: it must never interrupt a launch, and a user who is asked
  /// about backups is a user who is being made responsible for our bugs.
  Future<File?> snapshotIfDue({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final dir = await _snapshotsDirectory();
    final existing = await listSnapshots();

    if (existing.isNotEmpty) {
      final newest = snapshotTakenAt(existing.first);
      if (newest != null && at.difference(newest) < snapshotInterval) {
        return null;
      }
    }

    final stamp = '${at.year}${_two(at.month)}${_two(at.day)}'
        '-${_two(at.hour)}${_two(at.minute)}${_two(at.second)}';
    final target = File(p.join(dir.path, 'chronus-$stamp.sqlite'));
    if (target.existsSync()) target.deleteSync();

    // Same reasoning as export(): VACUUM INTO is transactionally consistent
    // against a live database and folds in un-checkpointed WAL content, and it
    // emits a single file with no -wal sidecar to go stale beside it.
    await _db.customStatement('VACUUM INTO ?', [target.path]);

    for (final stale in (await listSnapshots()).skip(snapshotsToKeep)) {
      try {
        stale.deleteSync();
      } catch (_) {
        // A snapshot we cannot delete is only wasted disk.
      }
    }
    return target;
  }

  /// Snapshots, newest first.
  ///
  /// Ordered by the timestamp **in the file name**, not by modification time.
  /// Copying a folder resets mtimes, and users do move this directory between
  /// PCs — mtime ordering would then prune the wrong files, or decide a snapshot
  /// is not due when it is. The name is the only record of when a snapshot was
  /// actually taken, so it is the one to trust.
  Future<List<File>> listSnapshots() async {
    final dir = Directory(p.join((await _appDir()).path, snapshotsDirName));
    if (!dir.existsSync()) return const [];
    final files = [
      for (final entity in dir.listSync())
        if (entity is File && snapshotTakenAt(entity) != null) entity,
    ];
    // Zero-padded stamps, so lexicographic order is chronological order.
    files.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return files;
  }

  static final _snapshotName =
      RegExp(r'^chronus-(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})\.sqlite$');

  /// When a snapshot was taken, read from its name. Null if the file is not one
  /// of ours — which is also what keeps [listSnapshots] from offering to restore
  /// some unrelated `.sqlite` a user dropped in the folder.
  static DateTime? snapshotTakenAt(File file) {
    final match = _snapshotName.firstMatch(p.basename(file.path));
    if (match == null) return null;
    int group(int i) => int.parse(match.group(i)!);
    return DateTime(
        group(1), group(2), group(3), group(4), group(5), group(6));
  }

  /// Replaces the database contents with a snapshot's, **leaving `media/`
  /// alone**.
  ///
  /// That asymmetry with [import] is deliberate, not an oversight. A snapshot
  /// holds no photos, so wiping media the way a bundle restore does would delete
  /// every photo the user has. Left alone, the files on disk are a superset of
  /// what the restored rows reference: photos added since the snapshot become
  /// unreferenced clutter, and one deleted since it renders as a broken
  /// thumbnail — both strictly better than losing the library.
  ///
  /// Destructive as to rows. Callers must confirm with the user first.
  Future<void> restoreSnapshot(File snapshot) async {
    if (!snapshot.existsSync()) {
      throw ArgumentError('Snapshot not found: ${snapshot.path}');
    }
    // Copied first: _migrateToCurrentSchema opens it writably to run pending
    // migrations, and a snapshot must stay a valid restore point afterwards
    // rather than being consumed by the attempt.
    final staging = Directory(p.join((await _appDir()).path, '.snapshot-staging'));
    if (staging.existsSync()) staging.deleteSync(recursive: true);
    staging.createSync(recursive: true);
    try {
      final working = snapshot.copySync(p.join(staging.path, 'snapshot.sqlite'));
      await _migrateToCurrentSchema(working);
      await _copyTablesFrom(working);
      _db.notifyUpdates({
        for (final table in _db.allTables)
          TableUpdate(table.actualTableName, kind: UpdateKind.update),
      });
    } finally {
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }

  Future<Directory> _snapshotsDirectory() async {
    final base = await _appDir();
    return Directory(p.join(base.path, snapshotsDirName))
        .create(recursive: true);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

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
