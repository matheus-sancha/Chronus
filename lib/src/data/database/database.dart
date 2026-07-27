import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/diagnostics/application/diagnostics.dart';
import '../app_directory.dart';
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
    StudyOperations,
    Observations,
    OperationInstances,
    OperationTimeSegments,
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
  int get schemaVersion => 6;

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
          if (from < 3) {
            // Timing moved from a single start/end span on operation_instances
            // to a child operation_time_segments table (per-operation snapshot
            // timing, pausable, concurrent), plus a manual-override column.
            // No released data exists, so drop the old span columns by
            // recreating the table rather than migrating any rows.
            await customStatement(
                'ALTER TABLE operation_instances RENAME TO _oi_old');
            await m.createTable(operationInstances);
            await customStatement('''
              INSERT INTO operation_instances
                (id, observation_id, study_operation_id, notes, created_at)
              SELECT id, observation_id, study_operation_id, notes, created_at
              FROM _oi_old
            ''');
            await customStatement('DROP TABLE _oi_old');
            await m.createTable(operationTimeSegments);
          }
          if (from < 4) {
            // Workspace pace alerts. Defaults to on, so an existing database
            // gains the feature rather than silently opting out of it.
            await m.addColumn(appSettings, appSettings.alertSoundsEnabled);
          }
          if (from < 5) {
            // Sampling Study sample-size criteria, per study (DESIGN.md §11.5).
            // Both carry defaults, so existing studies arrive at the conventional
            // 95 % / ±5 % rather than at null — there is no "unset" that the
            // adequacy calculation could meaningfully report on.
            await m.addColumn(studies, studies.confidenceLevel);
            await m.addColumn(studies, studies.relativePrecision);
          }
          if (from < 6) {
            // Phase 7 (DESIGN.md §11.10). The first migration that rebuilds a
            // table rather than adding to one, hence the order below: the
            // additive steps first, so a failure in the rebuild leaves the least
            // behind, and the backfill last, so it runs against final tables.

            // Exclusion, at both grains (§11.3). Nullable with no default —
            // "never excluded" is exactly null, and every existing row is.
            await m.addColumn(observations, observations.excludedAt);
            await m.addColumn(observations, observations.exclusionReason);
            if (from >= 3) {
              // Only from 3 upwards. The 2 -> 3 step above rebuilds
              // operation_instances with `m.createTable`, which builds it from
              // the CURRENT Dart definition — so on a v1/v2 database the table
              // already arrives here carrying these columns, and adding them
              // again fails the whole upgrade.
              //
              // The same guard is needed by any future column added to
              // operation_instances or operation_time_segments, for the same
              // reason. `observations` above needs none: no migration step
              // creates it, so it is always the shape its own version had.
              await m.addColumn(
                  operationInstances, operationInstances.excludedAt);
              await m.addColumn(
                  operationInstances, operationInstances.exclusionReason);
            }
            await m.addColumn(studies, studies.nextPassIndex);

            // study_operations.catalog_operation_id stops being a foreign key
            // and becomes a snapshot value (§11.8), so tidying the catalog can
            // no longer null out the key cross-study comparison matches on.
            //
            // alterTable does the rename/create/copy/drop dance BY EXPLICIT
            // COLUMN NAME — §2's rule, and the reason a hand-written `SELECT *`
            // would be wrong here: this table has itself been rebuilt before, so
            // its column order on an upgraded database need not match a freshly
            // created one. It also holds `legacy_alter_table` during the rename,
            // without which the rename would rewrite operation_instances' own
            // foreign key to point at the temporary table.
            await m.alterTable(TableMigration(studyOperations));

            // Every study owns pass 1 (§11.1). Studies that were opened but
            // never timed have no observation at all, and the invariant the rest
            // of Phase 7 is built on is that one always exists.
            //
            // sequenceIndex 0, matching what the engine has always inserted —
            // 1 here would collide with the next pass created for a study that
            // already had one.
            //
            // Written through the typed API rather than as raw SQL, which is
            // safe *here* specifically: both tables match the current Dart
            // definitions by this point (observations was just brought up to
            // date by the addColumns above, and v6 does not touch studies), so
            // there is no older shape for the mapping to disagree with. It
            // buys the same ids the engine generates and Drift's own DateTime
            // encoding, instead of hand-rolling both in SQL.
            final withoutPass = await select(studies).get();
            final have =
                (await select(observations).get()).map((o) => o.studyId).toSet();
            final now = DateTime.now();
            await batch((b) {
              for (final study in withoutPass) {
                if (have.contains(study.id)) continue;
                b.insert(
                  observations,
                  ObservationsCompanion.insert(
                    id: _uuid.v4(),
                    studyId: study.id,
                    sequenceIndex: 0,
                    // The study's own date, not today's: a pass backfilled for a
                    // study run in March did not happen at upgrade time.
                    performedAt: study.performedAt,
                    createdAt: now,
                  ),
                );
              }
            });

            // The never-reused pass counter (§11.3), seeded past whatever each
            // study already has. Last, so the backfilled passes above are
            // counted — a study seeded to 0 would hand pass 1's number out
            // again on the first Add pass.
            await customStatement(
              'UPDATE studies SET next_pass_index = COALESCE('
              '(SELECT MAX(o.sequence_index) + 1 FROM observations o '
              'WHERE o.study_id = studies.id), 1)',
            );
          }
        },
        beforeOpen: (details) async {
          // SQLite has foreign keys OFF by default; enforce them every open.
          await customStatement('PRAGMA foreign_keys = ON');
          // Schema state goes in the log here rather than in the session header,
          // because the database opens lazily on first query — long after the
          // header is written. "Fresh install or upgrade?" answers a surprising
          // share of reports on its own (DESIGN.md §10).
          Diag.event(
            'db',
            'schema ${details.versionNow}'
                '${details.wasCreated ? ' created' : ''}'
                '${details.hadUpgrade ? ' upgraded from ${details.versionBefore}' : ''}',
          );
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
      final dir = await appDataDirectory();
      final file = File(p.join(dir.path, 'chronus.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
