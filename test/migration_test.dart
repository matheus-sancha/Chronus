import 'dart:io';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/settings/data/settings_repository.dart';
import 'package:chronus/src/features/templates/data/template_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v1 -> v2 backfills template operation snapshots from the catalog',
      () async {
    final dir = await Directory.systemTemp.createTemp('chronus_migration');
    final file = File('${dir.path}/chronus.sqlite');

    // Build a minimal v1 database by hand (the old template_operations schema:
    // a pure catalog reference, no snapshot columns).
    final v1 = sqlite3.open(file.path);
    v1.execute('''
      CREATE TABLE templates (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        default_study_type TEXT NOT NULL,
        default_allowance_percent REAL NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
    ''');
    v1.execute('''
      CREATE TABLE operation_subtypes (
        id TEXT NOT NULL PRIMARY KEY, category TEXT NOT NULL, name TEXT NOT NULL,
        is_built_in INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
    ''');
    v1.execute('''
      CREATE TABLE catalog_operations (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL,
        subtype_id TEXT, reference_standard_ms INTEGER,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
    ''');
    v1.execute('''
      CREATE TABLE template_operations (
        id TEXT NOT NULL PRIMARY KEY, template_id TEXT NOT NULL,
        catalog_operation_id TEXT NOT NULL, order_index REAL NOT NULL,
        created_at INTEGER NOT NULL);
    ''');
    // operation_instances existed in v1 with a single start/end span; the
    // 2 -> 3 upgrade rebuilds it into the segment model. Present here so that
    // migration step has a table to rebuild.
    v1.execute('''
      CREATE TABLE operation_instances (
        id TEXT NOT NULL PRIMARY KEY, observation_id TEXT NOT NULL,
        study_operation_id TEXT NOT NULL, start_at_ms INTEGER, end_at_ms INTEGER,
        rating_percent REAL NOT NULL DEFAULT 100, notes TEXT,
        created_at INTEGER NOT NULL);
    ''');
    // Likewise app_settings: the 3 -> 4 upgrade adds a column to it, so it has
    // to exist here for that step to have something to alter.
    v1.execute('''
      CREATE TABLE app_settings (
        id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, locale_code TEXT,
        default_analyst TEXT, time_unit TEXT NOT NULL,
        updated_at INTEGER NOT NULL);
    ''');
    v1.execute("INSERT INTO app_settings VALUES (0,NULL,NULL,'seconds',0)");
    v1.execute("INSERT INTO catalog_operations VALUES "
        "('c1','Load part','productive',NULL,4500,0,0)");
    v1.execute("INSERT INTO templates VALUES ('t1','Cycle','timeStudy',0,0,0)");
    v1.execute("INSERT INTO template_operations VALUES ('o1','t1','c1',1.0,0)");
    v1.execute('PRAGMA user_version = 1');
    v1.close();

    // Opening the current schema triggers the 1 -> 2 upgrade.
    final db = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    final ops = await TemplateRepository(db).watchOperations('t1').first;
    expect(ops, hasLength(1));
    expect(ops.single.name, 'Load part'); // backfilled from catalog
    expect(ops.single.category, OperationCategory.productive);
    expect(ops.single.referenceStandardMs, 4500);
    expect(ops.single.catalogOperationId, 'c1'); // link preserved
  });

  test('v3 -> v4 adds alert sounds, defaulting existing databases to on',
      () async {
    final dir = await Directory.systemTemp.createTemp('chronus_migration_v4');
    final file = File('${dir.path}/chronus.sqlite');

    // A v3 app_settings row: no alert_sounds_enabled column yet.
    final v3 = sqlite3.open(file.path);
    v3.execute('''
      CREATE TABLE app_settings (
        id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, locale_code TEXT,
        default_analyst TEXT, time_unit TEXT NOT NULL,
        updated_at INTEGER NOT NULL);
    ''');
    v3.execute("INSERT INTO app_settings VALUES (0,'pt','M. Sancha','seconds',0)");
    v3.execute('PRAGMA user_version = 3');
    v3.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    final settings = await SettingsRepository(db).watch().first;
    // Existing users gain the feature rather than silently opting out of it.
    expect(settings.alertSoundsEnabled, isTrue);
    // ...and the rest of the row survives the upgrade untouched.
    expect(settings.localeCode, 'pt');
    expect(settings.defaultAnalyst, 'M. Sancha');
    expect(settings.timeUnit, TimeUnit.seconds);
  });
}
