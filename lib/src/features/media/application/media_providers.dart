import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/app_directory.dart';
import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../../../data/database/enums.dart';
import '../data/media_repository.dart';

part 'media_providers.g.dart';

@riverpod
MediaRepository mediaRepository(Ref ref) {
  return MediaRepository(
    ref.watch(appDatabaseProvider),
    appDataDirectory,
  );
}

/// The app's base directory path, resolved once (for building image file paths).
@riverpod
Future<String> appMediaBasePath(Ref ref) async {
  final dir = await appDataDirectory();
  return dir.path;
}

/// Attachments for one owner (study / observation / operation-instance).
final mediaForOwnerProvider = StreamProvider.family<List<MediaAttachment>,
    (MediaOwnerType, String)>((ref, key) {
  return ref.watch(mediaRepositoryProvider).watchForOwner(key.$1, key.$2);
});

/// Photo/video counts per operation-instance owner id, for row indicators.
final operationMediaCountsProvider =
    StreamProvider<Map<String, int>>((ref) {
  return ref
      .watch(mediaRepositoryProvider)
      .watchByOwnerType(MediaOwnerType.operationInstance)
      .map((list) {
    final counts = <String, int>{};
    for (final m in list) {
      counts[m.ownerId] = (counts[m.ownerId] ?? 0) + 1;
    }
    return counts;
  });
});
