import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'enums.dart';
import 'tables.dart';

part 'database.g.dart';

const _uuid = Uuid();

/// The 7 wastes, seeded as built-in subtypes under `unproductive`.
const _wasteSubtypes = <String>[
  'Waiting',
  'Motion',
  'Transportation',
  'Over-processing',
  'Overproduction',
  'Inventory',
  'Defects',
];

/// Seed values for the editable Process Type picklist.
const _processTypeSeeds = <String>[
  'Machining',
  'Cladding',
  'Welding',
  'Assembly & Testing',
  'Inspection',
  'Bending',
];

@DriftDatabase(
  tables: [
    Projects,
    OperationSubtypes,
    CatalogOperations,
    Studies,
    StudyAllowanceOverrides,
    StudyOperations,
    Observations,
    OperationInstances,
    Templates,
    TemplateOperations,
    ProcessTypeOptions,
    MediaAttachments,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database. Pass an explicit [executor] (e.g.
  /// `NativeDatabase.memory()`) in tests to run against an in-memory database.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openOnDevice());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedReferenceData();
        },
        beforeOpen: (details) async {
          // SQLite has foreign keys OFF by default; enforce them every open.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedReferenceData() async {
    final now = DateTime.now();
    await batch((b) {
      b.insertAll(operationSubtypes, [
        for (final name in _wasteSubtypes)
          OperationSubtypesCompanion.insert(
            id: _uuid.v4(),
            category: OperationCategory.unproductive,
            name: name,
            isBuiltIn: const Value(true),
            createdAt: now,
          ),
      ]);
      var order = 0;
      b.insertAll(processTypeOptions, [
        for (final name in _processTypeSeeds)
          ProcessTypeOptionsCompanion.insert(
            id: _uuid.v4(),
            name: name,
            isBuiltIn: const Value(true),
            sortOrder: Value(order++),
            createdAt: now,
          ),
      ]);
    });
  }

  static QueryExecutor _openOnDevice() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'chronus.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
