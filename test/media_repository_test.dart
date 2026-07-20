import 'dart:io';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/media/data/media_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late MediaRepository media;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('chronus_media');
    media = MediaRepository(db, () async => tempDir);
  });
  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<String> makeSource(String name, List<int> bytes) async {
    final f = File('${tempDir.path}/$name');
    await f.writeAsBytes(bytes);
    return f.path;
  }

  Future<MediaAttachment> add(String ownerId, String source) => media.addFile(
        ownerType: MediaOwnerType.operationInstance,
        ownerId: ownerId,
        kind: MediaKind.photo,
        sourcePath: source,
      );

  test('addFile copies into media/ and records a portable relative path',
      () async {
    final src = await makeSource('photo.png', [1, 2, 3]);
    final m = await add('op1', src);

    expect(m.relativePath, startsWith('media/'));
    expect(m.relativePath, endsWith('.png')); // extension preserved
    final abs = await media.absolutePath(m);
    expect(await File(abs).exists(), isTrue);
    expect(await File(abs).readAsBytes(), [1, 2, 3]); // content copied
  });

  test('watchForOwner scopes to the owner', () async {
    final src = await makeSource('a.jpg', [9]);
    await add('op1', src);
    await add('op2', src);
    expect(
        await media
            .watchForOwner(MediaOwnerType.operationInstance, 'op1')
            .first,
        hasLength(1));
  });

  test('remove deletes both the file and the row', () async {
    final src = await makeSource('b.jpg', [7]);
    final m = await add('op1', src);
    final abs = await media.absolutePath(m);

    await media.remove(m);

    expect(await File(abs).exists(), isFalse);
    expect(
        await media
            .watchForOwner(MediaOwnerType.operationInstance, 'op1')
            .first,
        isEmpty);
  });

  test('setCaption sets a trimmed caption and clears on blank', () async {
    final src = await makeSource('c.jpg', [5]);
    final m = await add('op1', src);

    await media.setCaption(m.id, '  before weld  ');
    var got = (await media
            .watchForOwner(MediaOwnerType.operationInstance, 'op1')
            .first)
        .single;
    expect(got.caption, 'before weld');

    await media.setCaption(m.id, '   ');
    got = (await media
            .watchForOwner(MediaOwnerType.operationInstance, 'op1')
            .first)
        .single;
    expect(got.caption, null);
  });
}
