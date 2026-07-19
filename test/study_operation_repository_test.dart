import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/catalog/data/catalog_repository.dart';
import 'package:chronus/src/features/projects/data/project_repository.dart';
import 'package:chronus/src/features/studies/data/study_operation_repository.dart';
import 'package:chronus/src/features/studies/data/study_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;
  late StudyOperationRepository sequence;
  late String studyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    catalog = CatalogRepository(db);
    sequence = StudyOperationRepository(db);
    final project = await ProjectRepository(db).create(name: 'P');
    final study = await StudyRepository(db).create(
      projectId: project.id,
      name: 'S',
      type: StudyType.timeStudy,
    );
    studyId = study.id;
  });
  tearDown(() => db.close());

  Future<CatalogOperation> catalogOp(String name) => catalog.create(
        name: name,
        category: OperationCategory.productive,
        referenceStandardMs: 4500,
      );

  test('adding from the catalog snapshots fields and appends in order',
      () async {
    await sequence.addFromCatalog(studyId: studyId, operation: await catalogOp('A'));
    await sequence.addFromCatalog(studyId: studyId, operation: await catalogOp('B'));

    final ops = await sequence.watchByStudy(studyId).first;
    expect(ops.map((o) => o.name), ['A', 'B']);
    expect(ops.map((o) => o.orderIndex), [1.0, 2.0]);
    expect(ops.first.referenceStandardMs, 4500);
    expect(ops.first.catalogOperationId, isNotNull);
  });

  test('snapshot is independent of later catalog edits', () async {
    final op = await catalogOp('Load');
    await sequence.addFromCatalog(studyId: studyId, operation: op);

    await catalog.update(
      id: op.id,
      name: 'Load (renamed)',
      category: OperationCategory.setup,
      referenceStandardMs: 9999,
    );

    final snap = (await sequence.watchByStudy(studyId).first).single;
    expect(snap.name, 'Load'); // unchanged
    expect(snap.category, OperationCategory.productive);
    expect(snap.referenceStandardMs, 4500);
  });

  test('reorder rewrites the sequence order', () async {
    await sequence.addFromCatalog(studyId: studyId, operation: await catalogOp('A'));
    await sequence.addFromCatalog(studyId: studyId, operation: await catalogOp('B'));
    await sequence.addFromCatalog(studyId: studyId, operation: await catalogOp('C'));

    var ops = await sequence.watchByStudy(studyId).first;
    final ids = ops.map((o) => o.id).toList();
    // Move C to the front.
    await sequence.reorder([ids[2], ids[0], ids[1]]);

    ops = await sequence.watchByStudy(studyId).first;
    expect(ops.map((o) => o.name), ['C', 'A', 'B']);
  });

  test('remove deletes one operation', () async {
    await sequence.addFromCatalog(studyId: studyId, operation: await catalogOp('A'));
    final op = (await sequence.watchByStudy(studyId).first).single;
    await sequence.remove(op.id);
    expect(await sequence.watchByStudy(studyId).first, isEmpty);
  });
}
