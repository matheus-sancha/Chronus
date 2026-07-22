// Dev tool: round-trips a REAL copied app directory through a .chronus bundle.
//
// Copy a real app directory somewhere safe, then:
//
//   CHRONUS_LIVE_COPY=/path/to/copy flutter test test/live_backup_check.dart
//
// Skips silently when that is unset. Unit tests use in-memory databases and toy
// rows; this exercises a real on-disk database (real row counts, real photo
// bytes) of the kind a user would actually be trusting the bundle with.
//
// Always point it at a COPY: it writes to the directory it is given.
import 'dart:io';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/features/backup/application/backup_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final _source = Platform.environment['CHRONUS_LIVE_COPY'] ?? '';

void main() {
  test('real app data survives a bundle round trip', () async {
    if (_source.isEmpty || !Directory(_source).existsSync()) {
      // ignore: avoid_print
      print('SKIPPED: set CHRONUS_LIVE_COPY to a copied app directory');
      return;
    }
    final source = Directory(_source);

    // Work on our own copy of the copy, so re-runs are repeatable.
    final work = await Directory.systemTemp.createTemp('chronus_live');
    addTearDown(() => work.deleteSync(recursive: true));
    for (final entity in source.listSync(recursive: true)) {
      if (entity is! File) continue;
      final target =
          File(p.join(work.path, p.relative(entity.path, from: source.path)));
      target.parent.createSync(recursive: true);
      entity.copySync(target.path);
    }

    final db = AppDatabase(
        NativeDatabase(File(p.join(work.path, 'chronus.sqlite'))));
    addTearDown(db.close);
    final backup = BackupService(db, () async => work);

    Future<Map<String, int>> counts() async => {
          for (final table in db.allTables)
            table.actualTableName: (await db
                    .customSelect('SELECT COUNT(*) c FROM ${table.actualTableName}')
                    .getSingle())
                .data['c']! as int,
        };

    final before = await counts();
    final mediaBefore = Directory(p.join(work.path, 'media'))
        .listSync()
        .whereType<File>()
        .map((f) => '${p.basename(f.path)}:${f.lengthSync()}')
        .toList()
      ..sort();

    final bytes = await backup.export();
    // ignore: avoid_print
    print('bundle: ${(bytes.length / 1024).toStringAsFixed(1)} KB '
        'from ${before.values.fold(0, (a, b) => a + b)} rows '
        'and ${mediaBefore.length} media files');

    // Wreck it, then restore.
    await db.customStatement('DELETE FROM projects');
    Directory(p.join(work.path, 'media')).deleteSync(recursive: true);

    final manifest = await backup.import(bytes);

    final after = await counts();
    final mediaAfter = Directory(p.join(work.path, 'media'))
        .listSync()
        .whereType<File>()
        .map((f) => '${p.basename(f.path)}:${f.lengthSync()}')
        .toList()
      ..sort();

    expect(after, before, reason: 'row counts must match table by table');
    expect(mediaAfter, mediaBefore, reason: 'every photo restored byte-exact');
    expect(manifest.schemaVersion, db.schemaVersion);

    final violations = await db.customSelect('PRAGMA foreign_key_check').get();
    expect(violations, isEmpty);

    // ignore: avoid_print
    print('restored OK — tables: ${before.length}, '
        'rows: ${before.values.fold(0, (a, b) => a + b)}, '
        'media: ${mediaAfter.length}, fk violations: 0');
  });
}
