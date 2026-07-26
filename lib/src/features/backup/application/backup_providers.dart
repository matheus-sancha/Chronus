import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/app_directory.dart';
import '../../../data/database/database_providers.dart';
import 'backup_service.dart';

part 'backup_providers.g.dart';

@riverpod
BackupService backupService(Ref ref) {
  return BackupService(
    ref.watch(appDatabaseProvider),
    appDataDirectory,
  );
}
