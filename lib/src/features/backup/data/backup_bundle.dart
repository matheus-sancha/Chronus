import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Layout of a `.chronus` bundle (a plain ZIP):
///
/// ```
///   manifest.json      format + schema version, so a bundle from a newer
///                      build can be refused with a clear message
///   chronus.sqlite     a VACUUM INTO snapshot, not a file copy
///   media/…            every attachment, at the same relative paths the
///                      database stores
/// ```
const bundleExtension = 'chronus';
const _manifestName = 'manifest.json';
const _databaseName = 'chronus.sqlite';
const _mediaPrefix = 'media/';

/// Bumped only when the bundle *layout* changes in a way older builds cannot
/// read — independent of the database schema version, which moves far more
/// often and is handled by migrating on import.
const currentBundleFormat = 1;

class BackupManifest {
  const BackupManifest({
    required this.format,
    required this.schemaVersion,
    required this.createdAt,
    required this.mediaCount,
  });

  final int format;

  /// Drift's `schemaVersion` at the time of writing. On import a bundle older
  /// than the running app is migrated forward; a newer one is refused, because
  /// migrating backwards is not something we can do correctly.
  final int schemaVersion;
  final DateTime createdAt;
  final int mediaCount;

  Map<String, Object?> toJson() => {
        'format': format,
        'schemaVersion': schemaVersion,
        'createdAt': createdAt.toIso8601String(),
        'mediaCount': mediaCount,
      };

  static BackupManifest fromJson(Map<String, Object?> json) => BackupManifest(
        format: (json['format'] as num).toInt(),
        schemaVersion: (json['schemaVersion'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        mediaCount: (json['mediaCount'] as num?)?.toInt() ?? 0,
      );
}

/// Why a bundle could not be restored. Carried as a typed reason so the UI can
/// explain the problem rather than surfacing a raw exception.
enum BackupProblem {
  notAZip,
  missingManifest,
  missingDatabase,
  formatTooNew,
  schemaTooNew,
}

class BackupException implements Exception {
  const BackupException(this.problem, [this.detail]);

  final BackupProblem problem;
  final String? detail;

  @override
  String toString() => 'BackupException(${problem.name}${detail == null ? '' : ': $detail'})';
}

/// Packs a database snapshot plus its media into bundle bytes.
///
/// [databaseSnapshot] must be a consistent copy — see
/// `BackupService.export`, which produces one with `VACUUM INTO`. Copying the
/// live database file instead would risk capturing it mid-write, and would
/// silently omit any un-checkpointed WAL contents.
Uint8List writeBundle({
  required File databaseSnapshot,
  required List<({String relativePath, File file})> media,
  required int schemaVersion,
  DateTime? createdAt,
}) {
  final archive = Archive();

  final manifest = BackupManifest(
    format: currentBundleFormat,
    schemaVersion: schemaVersion,
    createdAt: createdAt ?? DateTime.now(),
    mediaCount: media.length,
  );
  final manifestBytes =
      utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest.toJson()));
  archive.addFile(
      ArchiveFile(_manifestName, manifestBytes.length, manifestBytes));

  final dbBytes = databaseSnapshot.readAsBytesSync();
  archive.addFile(ArchiveFile(_databaseName, dbBytes.length, dbBytes));

  for (final entry in media) {
    if (!entry.file.existsSync()) continue;
    final bytes = entry.file.readAsBytesSync();
    // Always forward slashes: the same path the database stores, and the only
    // separator a ZIP should contain.
    final name = entry.relativePath.replaceAll(r'\', '/');
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  final zipped = ZipEncoder().encode(archive);
  if (zipped == null) throw StateError('ZIP encoding produced no bytes');
  return Uint8List.fromList(zipped);
}

/// A bundle unpacked onto disk, ready to be applied.
class UnpackedBundle {
  const UnpackedBundle({
    required this.manifest,
    required this.database,
    required this.mediaDirectory,
  });

  final BackupManifest manifest;
  final File database;

  /// Holds the bundle's `media/` tree; may be empty.
  final Directory mediaDirectory;
}

/// Validates and unpacks [bytes] into [destination].
///
/// Validation happens before anything is applied, so a bad bundle can never
/// leave the app half-restored.
UnpackedBundle unpackBundle({
  required Uint8List bytes,
  required Directory destination,
  required int supportedSchemaVersion,
}) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (e) {
    throw BackupException(BackupProblem.notAZip, '$e');
  }

  final manifestFile = archive.findFile(_manifestName);
  if (manifestFile == null) {
    throw const BackupException(BackupProblem.missingManifest);
  }
  final manifest = BackupManifest.fromJson(
    jsonDecode(utf8.decode(manifestFile.content as List<int>))
        as Map<String, Object?>,
  );

  if (manifest.format > currentBundleFormat) {
    throw BackupException(BackupProblem.formatTooNew, '${manifest.format}');
  }
  if (manifest.schemaVersion > supportedSchemaVersion) {
    throw BackupException(
        BackupProblem.schemaTooNew, '${manifest.schemaVersion}');
  }

  final dbEntry = archive.findFile(_databaseName);
  if (dbEntry == null) {
    throw const BackupException(BackupProblem.missingDatabase);
  }

  destination.createSync(recursive: true);
  final database = File(p.join(destination.path, _databaseName))
    ..writeAsBytesSync(dbEntry.content as List<int>);

  final mediaDirectory = Directory(p.join(destination.path, 'media'))
    ..createSync(recursive: true);
  for (final entry in archive) {
    if (!entry.isFile || !entry.name.startsWith(_mediaPrefix)) continue;
    // Refuse path traversal: a crafted bundle must not write outside the
    // destination directory.
    final target =
        File(p.joinAll([destination.path, ...entry.name.split('/')]));
    if (!p.isWithin(destination.path, target.path)) continue;
    target
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(entry.content as List<int>);
  }

  return UnpackedBundle(
    manifest: manifest,
    database: database,
    mediaDirectory: mediaDirectory,
  );
}
