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
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database. Pass an explicit [executor] (e.g.
  /// `NativeDatabase.memory()`) in tests to run against an in-memory database.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openOnDevice());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedReferenceData();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // template_operations became snapshot-based (nullable catalog link +
            // name/category/subtype/reference-standard). Rebuild it, backfilling
            // the snapshot fields from each referenced catalog operation.
            // (Foreign keys are off during migration — beforeOpen runs later.)
            await customStatement(
              'ALTER TABLE template_operations '
              'RENAME TO _template_operations_old',
            );
            await m.createTable(templateOperations);
            await customStatement('''
              INSERT INTO template_operations
                (id, template_id, catalog_operation_id, order_index,
                 name, category, subtype_id, reference_standard_ms, created_at)
              SELECT o.id, o.template_id, o.catalog_operation_id, o.order_index,
                     c.name, c.category, c.subtype_id, c.reference_standard_ms,
                     o.created_at
              FROM _template_operations_old o
              JOIN catalog_operations c ON c.id = o.catalog_operation_id
            ''');
            await customStatement('DROP TABLE _template_operations_old');
          }
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
      b.insert(
        appSettings,
        // Explicit id 0: the column is INTEGER PRIMARY KEY (a rowid alias), so
        // omitting it would auto-assign a rowid rather than use the DEFAULT.
        AppSettingsCompanion.insert(
          id: const Value(0),
          timeUnit: TimeUnit.seconds,
          updatedAt: now,
        ),
      );
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
