import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/settings_repository.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
}

/// The current app settings, guaranteed to exist (the row is created on first
/// read). Hand-written (not codegen) because it returns the Drift-generated
/// [AppSetting] type — see projects_providers.dart for the why.
final appSettingsProvider = StreamProvider<AppSetting>((ref) async* {
  final repo = ref.watch(settingsRepositoryProvider);
  await repo.ensureExists();
  yield* repo.watch();
});
