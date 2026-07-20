import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';

/// Manages [MediaAttachment]s. Files are copied into a `media/` folder under the
/// app directory and referenced by a **relative** path (never stored as blobs),
/// so they travel in the `.chronus` backup bundle and the iOS↔Windows migration.
/// The base directory is injected so tests can use a temp dir.
class MediaRepository {
  MediaRepository(this._db, this._appDir);

  final AppDatabase _db;

  /// Resolves the app's base directory (documents dir in the app; a temp dir in
  /// tests). The `media/` subfolder is created underneath it.
  final Future<Directory> Function() _appDir;

  static const _uuid = Uuid();

  Stream<List<MediaAttachment>> watchForOwner(
    MediaOwnerType ownerType,
    String ownerId,
  ) {
    return (_db.select(_db.mediaAttachments)
          ..where((t) =>
              t.ownerType.equalsValue(ownerType) & t.ownerId.equals(ownerId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// All attachments of a given owner type (used for at-a-glance counts).
  Stream<List<MediaAttachment>> watchByOwnerType(MediaOwnerType ownerType) {
    return (_db.select(_db.mediaAttachments)
          ..where((t) => t.ownerType.equalsValue(ownerType)))
        .watch();
  }

  /// Copies [sourcePath] into the media folder and records the attachment.
  Future<MediaAttachment> addFile({
    required MediaOwnerType ownerType,
    required String ownerId,
    required MediaKind kind,
    required String sourcePath,
    String? caption,
  }) async {
    final mediaDir = await _mediaDir();
    final id = _uuid.v4();
    final name = '$id${p.extension(sourcePath)}';
    await File(sourcePath).copy(p.join(mediaDir.path, name));
    // Always store the relative path with forward slashes for portability.
    final relativePath = 'media/$name';
    return _db.into(_db.mediaAttachments).insertReturning(
          MediaAttachmentsCompanion.insert(
            id: id,
            ownerType: ownerType,
            ownerId: ownerId,
            kind: kind,
            relativePath: relativePath,
            caption: Value(caption),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Deletes both the file on disk and the row.
  Future<void> remove(MediaAttachment media) async {
    final file = File(await absolutePath(media));
    if (await file.exists()) await file.delete();
    await (_db.delete(_db.mediaAttachments)..where((t) => t.id.equals(media.id)))
        .go();
  }

  Future<void> setCaption(String id, String? caption) {
    final value = (caption == null || caption.trim().isEmpty) ? null : caption.trim();
    return (_db.update(_db.mediaAttachments)..where((t) => t.id.equals(id)))
        .write(MediaAttachmentsCompanion(caption: Value(value)));
  }

  /// The absolute filesystem path for a stored attachment (for `Image.file`).
  Future<String> absolutePath(MediaAttachment media) async {
    final base = await _appDir();
    return p.joinAll([base.path, ...media.relativePath.split('/')]);
  }

  Future<Directory> _mediaDir() async {
    final base = await _appDir();
    final dir = Directory(p.join(base.path, 'media'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
