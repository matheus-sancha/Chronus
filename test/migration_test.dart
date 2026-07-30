import 'dart:io';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/settings/data/settings_repository.dart';
import 'package:chronus/src/features/templates/data/template_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// The v5 shape of the tables the 5 -> 6 step touches.
///
/// Every fixture below needs these, whatever version it starts from, for the
/// same reason the older fixtures already carry `studies` and `app_settings`: a
/// migration step has to have something to alter. `IF NOT EXISTS` so a fixture
/// that deliberately defines an older shape of one of them (the v1
/// `operation_instances`, which the 2 -> 3 step rebuilds) keeps its own.
void _createV5TimingTables(Database db) {
  // app_settings and operation_subtypes exist in every real database from v1,
  // and the starter-catalog seeding (§9) reads both on every upgrade. The
  // fixtures that predate them get them here for the same reason they get
  // `studies`: a migration step has to have something to work against.
  db.execute('''
    CREATE TABLE IF NOT EXISTS app_settings (
      id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, locale_code TEXT,
      default_analyst TEXT, time_unit TEXT NOT NULL,
      alert_sounds_enabled INTEGER NOT NULL DEFAULT 1,
      updated_at INTEGER NOT NULL);
  ''');
  // Named columns, not positional: a fixture that built the older five-column
  // app_settings itself keeps its own shape, and this still fills the row.
  db.execute('INSERT OR IGNORE INTO app_settings (id, time_unit, updated_at) '
      "VALUES (0, 'seconds', 0)");
  db.execute('''
    CREATE TABLE IF NOT EXISTS operation_subtypes (
      id TEXT NOT NULL PRIMARY KEY, category TEXT NOT NULL, name TEXT NOT NULL,
      is_built_in INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
  ''');
  for (final name in [
    'Waiting',
    'Motion',
    'Transportation',
    'Over-processing',
    'Overproduction',
    'Inventory',
    'Defects',
  ]) {
    db.execute('INSERT OR IGNORE INTO operation_subtypes VALUES '
        "('st-$name', 'unproductive', '$name', 1, 0)");
  }
  db.execute('''
    CREATE TABLE IF NOT EXISTS catalog_operations (
      id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL,
      subtype_id TEXT, reference_standard_ms INTEGER,
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
  ''');
  // catalog_operation_id still carries the foreign key that v6 drops.
  db.execute('''
    CREATE TABLE IF NOT EXISTS study_operations (
      id TEXT NOT NULL PRIMARY KEY,
      study_id TEXT NOT NULL REFERENCES studies (id) ON DELETE CASCADE,
      catalog_operation_id TEXT REFERENCES catalog_operations (id) ON DELETE SET NULL,
      order_index REAL NOT NULL, name TEXT NOT NULL, category TEXT NOT NULL,
      subtype_id TEXT, reference_standard_ms INTEGER,
      is_unplanned INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS observations (
      id TEXT NOT NULL PRIMARY KEY,
      study_id TEXT NOT NULL REFERENCES studies (id) ON DELETE CASCADE,
      sequence_index INTEGER NOT NULL, performed_at INTEGER NOT NULL,
      notes TEXT, created_at INTEGER NOT NULL,
      UNIQUE (study_id, sequence_index));
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS operation_instances (
      id TEXT NOT NULL PRIMARY KEY,
      observation_id TEXT NOT NULL REFERENCES observations (id) ON DELETE CASCADE,
      study_operation_id TEXT NOT NULL REFERENCES study_operations (id) ON DELETE CASCADE,
      manual_actual_ms INTEGER, completed_at INTEGER, notes TEXT,
      created_at INTEGER NOT NULL,
      UNIQUE (observation_id, study_operation_id));
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS operation_time_segments (
      id TEXT NOT NULL PRIMARY KEY,
      operation_instance_id TEXT NOT NULL REFERENCES operation_instances (id) ON DELETE CASCADE,
      start_at_ms INTEGER NOT NULL, end_at_ms INTEGER, created_at INTEGER NOT NULL);
  ''');
}

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
    // And `studies`: the 4 -> 5 upgrade adds two columns to it, so it has to
    // exist here for that step to have something to alter.
    v1.execute('''
      CREATE TABLE studies (
        id TEXT NOT NULL PRIMARY KEY, project_id TEXT NOT NULL,
        type TEXT NOT NULL, name TEXT NOT NULL, performed_at INTEGER NOT NULL,
        analyst TEXT, part_product TEXT, process_operation TEXT,
        machine_workstation TEXT, line_cell TEXT, operator_name TEXT,
        shift TEXT, work_order_number TEXT, process_type TEXT, notes TEXT,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
    ''');
    v1.execute("INSERT INTO app_settings VALUES (0,NULL,NULL,'seconds',0)");
    v1.execute("INSERT INTO catalog_operations VALUES "
        "('c1','Load part','productive',NULL,4500,0,0)");
    v1.execute("INSERT INTO templates VALUES ('t1','Cycle','timeStudy',0,0,0)");
    v1.execute("INSERT INTO template_operations VALUES ('o1','t1','c1',1.0,0)");
    // After the fixture's own rows: the helper inserts a settings row only if
    // one is missing, and this fixture writes its own.
    _createV5TimingTables(v1);
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
    // Present for the same reason as above: 4 -> 5 alters `studies`.
    v3.execute('''
      CREATE TABLE studies (
        id TEXT NOT NULL PRIMARY KEY, project_id TEXT NOT NULL,
        type TEXT NOT NULL, name TEXT NOT NULL, performed_at INTEGER NOT NULL,
        analyst TEXT, part_product TEXT, process_operation TEXT,
        machine_workstation TEXT, line_cell TEXT, operator_name TEXT,
        shift TEXT, work_order_number TEXT, process_type TEXT, notes TEXT,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
    ''');
    _createV5TimingTables(v3);
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

  test('v4 -> v5 gives existing studies the conventional sample-size criteria',
      () async {
    final dir = await Directory.systemTemp.createTemp('chronus_migration_v5');
    final file = File('${dir.path}/chronus.sqlite');

    // A v4 studies row: no confidence_level or relative_precision yet.
    final v4 = sqlite3.open(file.path);
    v4.execute('''
      CREATE TABLE projects (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, notes TEXT,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
    ''');
    v4.execute('''
      CREATE TABLE studies (
        id TEXT NOT NULL PRIMARY KEY, project_id TEXT NOT NULL,
        type TEXT NOT NULL, name TEXT NOT NULL, performed_at INTEGER NOT NULL,
        analyst TEXT, part_product TEXT, process_operation TEXT,
        machine_workstation TEXT, line_cell TEXT, operator_name TEXT,
        shift TEXT, work_order_number TEXT, process_type TEXT, notes TEXT,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
    ''');
    v4.execute("INSERT INTO projects VALUES ('p1','Cell 4',NULL,0,0)");
    v4.execute("INSERT INTO studies VALUES "
        "('s1','p1','samplingStudy','Repeat study',0,'M. Sancha',"
        "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0)");
    _createV5TimingTables(v4);
    v4.execute('PRAGMA user_version = 4');
    v4.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    final study = await db.select(db.studies).getSingle();
    // Defaults, not nulls: there is no "unset" the adequacy calculation could
    // report on, so an existing study arrives at the conventional criteria.
    expect(study.confidenceLevel, 0.95);
    expect(study.relativePrecision, 0.05);
    // ...and nothing else about the study moved.
    expect(study.name, 'Repeat study');
    expect(study.type, StudyType.samplingStudy);
    expect(study.analyst, 'M. Sancha');
  });

  // v5 -> v6 is the first migration that REBUILDS a table rather than adding to
  // one (DESIGN.md §11.10), so these go past "the new columns exist" and pin the
  // things a rebuild is capable of quietly breaking.
  group('v5 -> v6', () {
    late Directory dir;
    late File file;

    /// A v5 database: no exclusion columns, catalog_operation_id still a foreign
    /// key, and studies that may or may not have an observation.
    Future<Database> openV5() async {
      dir = await Directory.systemTemp.createTemp('chronus_migration_v6');
      file = File('${dir.path}/chronus.sqlite');
      final v5 = sqlite3.open(file.path);
      v5.execute('''
        CREATE TABLE projects (
          id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, notes TEXT,
          created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
      v5.execute('''
        CREATE TABLE studies (
          id TEXT NOT NULL PRIMARY KEY, project_id TEXT NOT NULL,
          type TEXT NOT NULL, name TEXT NOT NULL, performed_at INTEGER NOT NULL,
          analyst TEXT, part_product TEXT, process_operation TEXT,
          machine_workstation TEXT, line_cell TEXT, operator_name TEXT,
          shift TEXT, work_order_number TEXT, process_type TEXT, notes TEXT,
          confidence_level REAL NOT NULL DEFAULT 0.95,
          relative_precision REAL NOT NULL DEFAULT 0.05,
          created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
      _createV5TimingTables(v5);
      v5.execute("INSERT INTO projects VALUES ('p1','Cell 4',NULL,0,0)");
      v5.execute("INSERT INTO catalog_operations VALUES "
          "('c1','Weld seam','productive',NULL,75000,0,0)");
      return v5;
    }

    Future<AppDatabase> upgrade() async {
      final db = AppDatabase(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        await dir.delete(recursive: true);
      });
      return db;
    }

    test('backfills pass 1 only for studies that have none, at index 0',
        () async {
      final v5 = await openV5();
      // s1 was opened but never timed: no observation at all.
      v5.execute("INSERT INTO studies VALUES "
          "('s1','p1','samplingStudy','Never timed',1000,NULL,"
          "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.95,0.05,0,0)");
      // s2 already has one, and must not gain a second.
      v5.execute("INSERT INTO studies VALUES "
          "('s2','p1','timeStudy','Timed',2000,NULL,"
          "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.95,0.05,0,0)");
      v5.execute("INSERT INTO observations VALUES ('o2','s2',0,2000,NULL,0)");
      v5.execute('PRAGMA user_version = 5');
      v5.close();

      final db = await upgrade();
      final all = await db.select(db.observations).get();
      expect(all, hasLength(2));

      final backfilled = all.firstWhere((o) => o.studyId == 's1');
      // 0, not 1 — the engine has always inserted 0, and 1 here would collide
      // with the next pass created for a study that already had one.
      expect(backfilled.sequenceIndex, 0);
      // The study's own date, not the upgrade's.
      expect(backfilled.performedAt, DateTime.fromMillisecondsSinceEpoch(1000000));
      expect(backfilled.excludedAt, isNull);

      // s2 keeps exactly the pass it had.
      expect(all.where((o) => o.studyId == 's2').map((o) => o.id), ['o2']);
    });

    test('seeds the pass counter past whatever each study already has',
        () async {
      final v5 = await openV5();
      v5.execute("INSERT INTO studies VALUES "
          "('s1','p1','samplingStudy','Three passes',1000,NULL,"
          "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.95,0.05,0,0)");
      v5.execute("INSERT INTO observations VALUES ('o1','s1',0,1000,NULL,0)");
      v5.execute("INSERT INTO observations VALUES ('o2','s1',1,1000,NULL,0)");
      v5.execute("INSERT INTO observations VALUES ('o3','s1',2,1000,NULL,0)");
      // s2 gets its pass from the backfill, so the counter has to be seeded
      // after that step rather than from the empty table it started with.
      v5.execute("INSERT INTO studies VALUES "
          "('s2','p1','timeStudy','Never timed',1000,NULL,"
          "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.95,0.05,0,0)");
      v5.execute('PRAGMA user_version = 5');
      v5.close();

      final db = await upgrade();
      final byId = {
        for (final s in await db.select(db.studies).get()) s.id: s.nextPassIndex
      };
      expect(byId['s1'], 3); // past 0, 1, 2
      expect(byId['s2'], 1); // past the backfilled pass 0
    });

    test('the study_operations rebuild keeps its rows and its dependants',
        () async {
      final v5 = await openV5();
      v5.execute("INSERT INTO studies VALUES "
          "('s1','p1','samplingStudy','Bracket weld',1000,NULL,"
          "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.95,0.05,0,0)");
      v5.execute("INSERT INTO observations VALUES ('o1','s1',0,1000,NULL,0)");
      v5.execute("INSERT INTO study_operations VALUES "
          "('so1','s1','c1',1.0,'Weld seam','productive',NULL,75000,0,0)");
      v5.execute("INSERT INTO operation_instances VALUES "
          "('i1','o1','so1',NULL,NULL,NULL,0)");
      v5.execute("INSERT INTO operation_time_segments VALUES "
          "('g1','i1',5000,8000,0)");
      v5.execute('PRAGMA user_version = 5');
      v5.close();

      final db = await upgrade();

      // Every column survives the copy, in the right place. A positional copy
      // would scramble these (DESIGN.md §2), and they are deliberately values
      // that would not look obviously wrong if two of them swapped.
      final op = await db.select(db.studyOperations).getSingle();
      expect(op.id, 'so1');
      expect(op.studyId, 's1');
      expect(op.catalogOperationId, 'c1');
      expect(op.orderIndex, 1.0);
      expect(op.name, 'Weld seam');
      expect(op.category, OperationCategory.productive);
      expect(op.referenceStandardMs, 75000);
      expect(op.isUnplanned, isFalse);

      // The rebuild renames study_operations out of the way. Without
      // legacy_alter_table held during that, SQLite rewrites the referencing
      // table's own foreign key to follow it — leaving operation_instances
      // pointing at a table that is about to be dropped.
      final instance = await db.select(db.operationInstances).getSingle();
      expect(instance.studyOperationId, 'so1');
      final segment = await db.select(db.operationTimeSegments).getSingle();
      expect(segment.operationInstanceId, 'i1');
      // Foreign keys are enforced again from beforeOpen; a dangling reference
      // left by the rebuild would surface here.
      final violations =
          await db.customSelect('PRAGMA foreign_key_check').get();
      expect(violations, isEmpty);
    });

    test('deleting a catalog operation no longer unmatches past studies',
        () async {
      final v5 = await openV5();
      v5.execute("INSERT INTO studies VALUES "
          "('s1','p1','timeStudy','March',1000,NULL,"
          "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.95,0.05,0,0)");
      v5.execute("INSERT INTO study_operations VALUES "
          "('so1','s1','c1',1.0,'Weld seam','productive',NULL,75000,0,0)");
      v5.execute('PRAGMA user_version = 5');
      v5.close();

      final db = await upgrade();
      await (db.delete(db.catalogOperations)..where((t) => t.id.equals('c1')))
          .go();

      // The whole point of §11.8: under the old foreign key this read null, and
      // the study silently dropped out of every cross-study comparison.
      final op = await db.select(db.studyOperations).getSingle();
      expect(op.catalogOperationId, 'c1');
    });
  });
}
