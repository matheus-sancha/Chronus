import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/settings/data/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });
  tearDown(() => db.close());

  test('seeded defaults: system locale, seconds, no analyst', () async {
    await repo.ensureExists();
    final settings = await repo.watch().first;
    expect(settings.localeCode, isNull);
    expect(settings.timeUnit, TimeUnit.seconds);
    expect(settings.defaultAnalyst, isNull);
  });

  test('updates persist and never create a second row', () async {
    await repo.ensureExists();
    await repo.setLocaleCode('pt');
    await repo.setDefaultAnalyst('Matheus');
    await repo.setTimeUnit(TimeUnit.decimalMinutes);

    final settings = await repo.watch().first;
    expect(settings.localeCode, 'pt');
    expect(settings.defaultAnalyst, 'Matheus');
    expect(settings.timeUnit, TimeUnit.decimalMinutes);
    expect(await db.select(db.appSettings).get(), hasLength(1));
  });

  test('clearing locale falls back to system (null)', () async {
    await repo.ensureExists();
    await repo.setLocaleCode('es');
    await repo.setLocaleCode(null);
    expect((await repo.watch().first).localeCode, isNull);
  });
}
