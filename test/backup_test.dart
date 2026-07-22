import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/backup/application/backup_service.dart';
import 'package:chronus/src/features/backup/data/backup_bundle.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory appDir;
  late BackupService backup;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    appDir = await Directory.systemTemp.createTemp('chronus_backup');
    backup = BackupService(db, () async => appDir);
  });

  tearDown(() async {
    await db.close();
    if (appDir.existsSync()) appDir.deleteSync(recursive: true);
  });

  Future<void> addProject(String id, String name) => db.into(db.projects).insert(
        ProjectsCompanion.insert(
          id: id,
          name: name,
          createdAt: DateTime(2026, 7, 21),
          updatedAt: DateTime(2026, 7, 21),
        ),
      );

  Future<void> addMediaRow(String id, String relativePath) =>
      db.into(db.mediaAttachments).insert(
            MediaAttachmentsCompanion.insert(
              id: id,
              ownerType: MediaOwnerType.operationInstance,
              ownerId: 'inst-1',
              kind: MediaKind.photo,
              relativePath: relativePath,
              createdAt: DateTime(2026, 7, 21),
            ),
          );

  File writeMedia(String name, List<int> bytes) {
    final file = File('${appDir.path}/media/$name');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    return file;
  }

  Future<List<String>> projectNames() async {
    final rows = await db.select(db.projects).get();
    return rows.map((r) => r.name).toList()..sort();
  }

  group('round trip', () {
    test('restores rows and media, discarding everything added since',
        () async {
      await addProject('p1', 'Cell 4 baseline');
      await addMediaRow('m1', 'media/photo.png');
      writeMedia('photo.png', [1, 2, 3, 4]);

      final bytes = await backup.export();

      // Diverge from the backup in every way it has to undo.
      await addProject('p2', 'Added after the backup');
      await (db.delete(db.projects)..where((t) => t.id.equals('p1'))).go();
      writeMedia('stray.png', [9, 9, 9]);
      File('${appDir.path}/media/photo.png').deleteSync();

      final manifest = await backup.import(bytes);

      expect(manifest.schemaVersion, db.schemaVersion);
      expect(await projectNames(), ['Cell 4 baseline']);
      expect(File('${appDir.path}/media/photo.png').readAsBytesSync(),
          [1, 2, 3, 4]);
      // Media not in the bundle is gone: restore is total, not a merge.
      expect(File('${appDir.path}/media/stray.png').existsSync(), isFalse);
    });

    test('keeps seeded reference data consistent rather than duplicating it',
        () async {
      // The 7 wastes are seeded on create; a restore must not stack a second
      // copy on top of the existing rows.
      final before = await db.select(db.operationSubtypes).get();
      expect(before, isNotEmpty);

      final bytes = await backup.export();
      await backup.import(bytes);

      final after = await db.select(db.operationSubtypes).get();
      expect(after.length, before.length);
    });

    test('survives a second restore of the same bundle', () async {
      await addProject('p1', 'Cell 4 baseline');
      final bytes = await backup.export();

      await backup.import(bytes);
      await backup.import(bytes);

      expect(await projectNames(), ['Cell 4 baseline']);
    });

    test('leaves foreign keys intact after the copy', () async {
      await addProject('p1', 'Cell 4 baseline');
      await db.into(db.studies).insert(StudiesCompanion.insert(
            id: 's1',
            projectId: 'p1',
            type: StudyType.timeStudy,
            name: 'Study',
            performedAt: DateTime(2026, 7, 21),
            createdAt: DateTime(2026, 7, 21),
            updatedAt: DateTime(2026, 7, 21),
          ));

      await backup.import(await backup.export());

      final violations =
          await db.customSelect('PRAGMA foreign_key_check').get();
      expect(violations, isEmpty);
      // And enforcement is back on afterwards, not left disabled.
      final pragma =
          await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(pragma.data.values.first, 1);
    });
  });

  group('rejects bundles it cannot honour', () {
    test('a bundle from a newer schema', () async {
      final snapshot = File('${appDir.path}/fake.sqlite')
        ..writeAsBytesSync([1, 2, 3]);
      final bytes = writeBundle(
        databaseSnapshot: snapshot,
        media: const [],
        schemaVersion: db.schemaVersion + 1,
      );

      await expectLater(
        backup.import(bytes),
        throwsA(isA<BackupException>().having(
            (e) => e.problem, 'problem', BackupProblem.schemaTooNew)),
      );
    });

    test('something that is not a zip at all', () async {
      await expectLater(
        backup.import(Uint8List.fromList(utf8Bytes('not a bundle'))),
        throwsA(isA<BackupException>()
            .having((e) => e.problem, 'problem', BackupProblem.notAZip)),
      );
    });

    test('a zip with no manifest', () async {
      final archive = Archive()
        ..addFile(ArchiveFile('chronus.sqlite', 3, [1, 2, 3]));
      final bytes = Uint8List.fromList(ZipEncoder().encode(archive)!);

      await expectLater(
        backup.import(bytes),
        throwsA(isA<BackupException>()
            .having((e) => e.problem, 'problem', BackupProblem.missingManifest)),
      );
    });

    test('a rejected bundle leaves existing data untouched', () async {
      await addProject('p1', 'Cell 4 baseline');
      final snapshot = File('${appDir.path}/fake.sqlite')
        ..writeAsBytesSync([1, 2, 3]);

      await expectLater(
        backup.import(writeBundle(
          databaseSnapshot: snapshot,
          media: const [],
          schemaVersion: db.schemaVersion + 99,
        )),
        throwsA(isA<BackupException>()),
      );

      expect(await projectNames(), ['Cell 4 baseline']);
    });
  });

  group('unpack safety', () {
    test('ignores entries that would escape the destination directory', () {
      final destination =
          Directory('${appDir.path}/unpack')..createSync(recursive: true);
      final escapee = ArchiveFile('media/../../escaped.png', 3, [1, 2, 3]);
      final archive = Archive()
        ..addFile(ArchiveFile(
            'manifest.json',
            0,
            utf8Bytes('{"format":1,"schemaVersion":${db.schemaVersion},'
                '"createdAt":"2026-07-21T09:30:00.000","mediaCount":1}')))
        ..addFile(ArchiveFile('chronus.sqlite', 3, [1, 2, 3]))
        ..addFile(escapee);

      unpackBundle(
        bytes: Uint8List.fromList(ZipEncoder().encode(archive)!),
        destination: destination,
        supportedSchemaVersion: db.schemaVersion,
      );

      expect(File('${appDir.path}/escaped.png').existsSync(), isFalse);
    });
  });
}

List<int> utf8Bytes(String s) => s.codeUnits;
