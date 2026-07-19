import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  const uuid = Uuid();
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seeds the 7 wastes and the process-type picklist on create', () async {
    final subtypes = await db.select(db.operationSubtypes).get();
    expect(subtypes, hasLength(7));
    expect(
      subtypes.every(
        (s) => s.isBuiltIn && s.category == OperationCategory.unproductive,
      ),
      isTrue,
    );

    final processTypes = await db.select(db.processTypeOptions).get();
    expect(processTypes, hasLength(6));
  });

  test('a full study hierarchy inserts and reads back', () async {
    final now = DateTime.now();
    final projectId = uuid.v4();
    await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            id: projectId,
            name: 'Line 3 optimization',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final studyId = uuid.v4();
    await db.into(db.studies).insert(
          StudiesCompanion.insert(
            id: studyId,
            projectId: projectId,
            type: StudyType.timeStudy,
            name: 'Baseline',
            performedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    final studyOpId = uuid.v4();
    await db.into(db.studyOperations).insert(
          StudyOperationsCompanion.insert(
            id: studyOpId,
            studyId: studyId,
            orderIndex: 1,
            name: 'Load part',
            category: OperationCategory.productive,
            createdAt: now,
          ),
        );

    final observationId = uuid.v4();
    await db.into(db.observations).insert(
          ObservationsCompanion.insert(
            id: observationId,
            studyId: studyId,
            sequenceIndex: 1,
            performedAt: now,
            createdAt: now,
          ),
        );

    await db.into(db.operationInstances).insert(
          OperationInstancesCompanion.insert(
            id: uuid.v4(),
            observationId: observationId,
            studyOperationId: studyOpId,
            startAtMs: const Value(1000),
            endAtMs: const Value(5500),
            createdAt: now,
          ),
        );

    final instance = await db.select(db.operationInstances).getSingle();
    expect(instance.endAtMs! - instance.startAtMs!, 4500);
    expect(instance.ratingPercent, 100.0); // default applied
  });

  test('foreign keys are enforced (bad projectId is rejected)', () async {
    final now = DateTime.now();
    expect(
      () => db.into(db.studies).insert(
            StudiesCompanion.insert(
              id: uuid.v4(),
              projectId: 'does-not-exist',
              type: StudyType.samplingStudy,
              name: 'Orphan',
              performedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a project cascades to its studies', () async {
    final now = DateTime.now();
    final projectId = uuid.v4();
    await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            id: projectId,
            name: 'Temp',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.studies).insert(
          StudiesCompanion.insert(
            id: uuid.v4(),
            projectId: projectId,
            type: StudyType.timeStudy,
            name: 'S1',
            performedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await (db.delete(db.projects)..where((t) => t.id.equals(projectId))).go();

    expect(await db.select(db.studies).get(), isEmpty);
  });
}
