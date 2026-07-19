import 'package:drift/drift.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';

/// Read/write access to the single-row [AppSettings]. Self-heals: if the row is
/// missing (e.g. an older database), [ensureExists] creates it with defaults.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;
  static const _rowId = 0;

  Future<void> ensureExists() async {
    final existing = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(_rowId)))
        .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.appSettings).insert(
            AppSettingsCompanion.insert(
              id: const Value(_rowId),
              timeUnit: TimeUnit.seconds,
              updatedAt: DateTime.now(),
            ),
          );
    }
  }

  Stream<AppSetting> watch() {
    return (_db.select(_db.appSettings)..where((t) => t.id.equals(_rowId)))
        .watchSingle();
  }

  /// Pass null to follow the system locale.
  Future<void> setLocaleCode(String? code) =>
      _update(AppSettingsCompanion(localeCode: Value(code)));

  Future<void> setDefaultAnalyst(String? analyst) =>
      _update(AppSettingsCompanion(defaultAnalyst: Value(analyst)));

  Future<void> setTimeUnit(TimeUnit unit) =>
      _update(AppSettingsCompanion(timeUnit: Value(unit)));

  Future<void> _update(AppSettingsCompanion changes) {
    return (_db.update(_db.appSettings)..where((t) => t.id.equals(_rowId)))
        .write(changes.copyWith(updatedAt: Value(DateTime.now())));
  }
}
