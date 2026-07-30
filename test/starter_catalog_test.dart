import 'dart:io';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/data/database/starter_catalog.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// The starter catalog (DESIGN.md §9).
///
/// The content is deliberately not asserted here — it is the one part of
/// Chronus specific to the people using it, and pinning the names would turn
/// every revision into a test edit. What is pinned is the behaviour that decides
/// whether someone is helped or overruled: the two guards.
void main() {
  test('a fresh install arrives with the catalog already populated', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final operations = await db.select(db.catalogOperations).get();
    expect(operations, hasLength(starterCatalog.length));

    // Every waste operation resolves a subtype — including the ones needing a
    // subtype the 7 built-ins do not cover, which are seeded alongside.
    final waste = operations
        .where((o) => o.category == OperationCategory.unproductive)
        .toList();
    expect(waste, isNotEmpty);
    expect(waste.every((o) => o.subtypeId != null), isTrue);

    final subtypes = await db.select(db.operationSubtypes).get();
    for (final starter in starterSubtypes) {
      final match = subtypes.firstWhere((s) => s.name == starter.name);
      // Not built-in: §3.4 reserves that for the 7 wastes, and these stay
      // deletable.
      expect(match.isBuiltIn, isFalse);
      expect(match.category, starter.category);
    }
    // The 7 wastes are untouched by the addition.
    expect(subtypes.where((s) => s.isBuiltIn), hasLength(7));

    // No invented benchmarks: a standard nobody measured would flow into
    // efficiency and pace alerts as though it meant something (§3.6).
    expect(operations.every((o) => o.referenceStandardMs == null), isTrue);

    final settings = await db.select(db.appSettings).getSingle();
    expect(settings.starterCatalogSeededAt, isNotNull);
  });

  test('opening an existing database again does not seed twice', () async {
    final dir = await Directory.systemTemp.createTemp('chronus_starter');
    final file = File('${dir.path}/chronus.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    // Reading is what opens the database, which is what runs onCreate.
    final seeded = (await first.select(first.catalogOperations).get()).length;
    expect(seeded, starterCatalog.length);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await second.close();
      await dir.delete(recursive: true);
    });
    expect((await second.select(second.catalogOperations).get()).length, seeded);
  });

  test('a colleague who emptied the catalog is not overruled on upgrade',
      () async {
    // The flag is the whole reason it exists: the empty-catalog check alone
    // would refill it on every drop, overriding a deliberate choice.
    final dir = await Directory.systemTemp.createTemp('chronus_starter_empty');
    final file = File('${dir.path}/chronus.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    await first.delete(first.catalogOperations).go();
    expect(await first.select(first.catalogOperations).get(), isEmpty);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await second.close();
      await dir.delete(recursive: true);
    });
    expect(await second.select(second.catalogOperations).get(), isEmpty);
  });

  group('upgrading from v6', () {
    /// A v6 database: the schema before the flag existed, with the seeded
    /// reference data a real one would have.
    Future<File> buildV6({required bool withCatalogRows}) async {
      final dir = await Directory.systemTemp.createTemp('chronus_starter_v6');
      final file = File('${dir.path}/chronus.sqlite');
      addTearDown(() => dir.delete(recursive: true));

      final v6 = sqlite3.open(file.path);
      v6.execute('''
        CREATE TABLE app_settings (
          id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, locale_code TEXT,
          default_analyst TEXT, time_unit TEXT NOT NULL,
          alert_sounds_enabled INTEGER NOT NULL DEFAULT 1,
          updated_at INTEGER NOT NULL);
      ''');
      v6.execute('''
        CREATE TABLE operation_subtypes (
          id TEXT NOT NULL PRIMARY KEY, category TEXT NOT NULL, name TEXT NOT NULL,
          is_built_in INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL);
      ''');
      v6.execute('''
        CREATE TABLE catalog_operations (
          id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL,
          subtype_id TEXT, reference_standard_ms INTEGER,
          created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
      v6.execute("INSERT INTO app_settings VALUES (0,NULL,NULL,'seconds',1,0)");
      // The 7 wastes, as a real database has them.
      for (final name in ['Waiting', 'Transportation', 'Defects']) {
        v6.execute("INSERT INTO operation_subtypes VALUES "
            "('st-$name','unproductive','$name',1,0)");
      }
      // ...and one of the subtypes the starter catalog needs, as a colleague
      // who already authored it themselves would have it. Name-matching has to
      // find this one rather than adding a second of the same name.
      v6.execute("INSERT INTO operation_subtypes VALUES "
          "('st-own','unproductive','${starterSubtypes.first.name}',0,0)");
      if (withCatalogRows) {
        v6.execute("INSERT INTO catalog_operations VALUES "
            "('own','Minha operação','productive',NULL,NULL,0,0)");
      }
      v6.execute('PRAGMA user_version = 6');
      v6.close();
      return file;
    }

    test('an existing install with an empty catalog gets one', () async {
      // The people already running Chronus are exactly who §9 is about, so the
      // seeding runs outside the version guards rather than only on create.
      final file = await buildV6(withCatalogRows: false);
      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final operations = await db.select(db.catalogOperations).get();
      expect(operations, hasLength(starterCatalog.length));
      // Every waste operation resolved a subtype, whether it was already in the
      // database or seeded alongside the catalog.
      expect(
        operations
            .where((o) => o.category == OperationCategory.unproductive)
            .every((o) => o.subtypeId != null),
        isTrue,
      );

      // Matched by NAME against what the database already had: the subtype the
      // colleague authored is reused, keeping their id, and no second one of
      // that name appears to split their waste Pareto in two.
      final reused = starterSubtypes.first.name;
      final subtypes = await db.select(db.operationSubtypes).get();
      expect(subtypes.where((s) => s.name == reused), hasLength(1));

      final needing = starterCatalog
          .where((o) => o.subtypeName == reused)
          .map((o) => o.name)
          .toSet();
      expect(needing, isNotEmpty);
      expect(
        operations
            .where((o) => needing.contains(o.name))
            .every((o) => o.subtypeId == 'st-own'),
        isTrue,
      );
    });

    test('an existing install that already has operations is left alone',
        () async {
      final file = await buildV6(withCatalogRows: true);
      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final operations = await db.select(db.catalogOperations).get();
      expect(operations, hasLength(1));
      expect(operations.single.name, 'Minha operação');

      // ...and it is marked as offered, so emptying the catalog tomorrow does
      // not read as "never seeded" and refill it.
      final settings = await db.select(db.appSettings).getSingle();
      expect(settings.starterCatalogSeededAt, isNotNull);
    });
  });
}
