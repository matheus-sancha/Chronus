import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'database.dart';

part 'database_providers.g.dart';

/// The single app-wide Drift database. Kept alive for the process lifetime and
/// closed on shutdown. Override in tests with an in-memory [AppDatabase].
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
