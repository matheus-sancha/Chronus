import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:chronus/src/features/projects/data/project_repository.dart';
import 'package:chronus/src/features/studies/data/study_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projects;
  late StudyRepository studies;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projects = ProjectRepository(db);
    studies = StudyRepository(db);
  });
  tearDown(() => db.close());

  Future<String> newProject() async {
    final project = await projects.create(name: 'P');
    return project.id;
  }

  test('create study and watch it within its project', () async {
    final projectId = await newProject();
    await studies.create(
      projectId: projectId,
      name: 'Baseline',
      type: StudyType.timeStudy,
      analyst: 'Matheus',
    );

    final list = await studies.watchByProject(projectId).first;
    expect(list, hasLength(1));
    expect(list.single.name, 'Baseline');
    expect(list.single.type, StudyType.timeStudy);
    expect(list.single.analyst, 'Matheus');
    expect(list.single.allowancePercent, 0.0); // default
  });

  test('studies are scoped to their project', () async {
    final a = await newProject();
    final b = await newProject();
    await studies.create(projectId: a, name: 'A1', type: StudyType.timeStudy);
    await studies.create(
      projectId: b,
      name: 'B1',
      type: StudyType.samplingStudy,
    );

    expect(await studies.watchByProject(a).first, hasLength(1));
    expect((await studies.watchByProject(b).first).single.name, 'B1');
  });

  test('update rewrites header fields', () async {
    final projectId = await newProject();
    final study = await studies.create(
      projectId: projectId,
      name: 'Draft',
      type: StudyType.timeStudy,
    );

    await studies.update(
      study.id,
      const StudiesCompanion(machineWorkstation: Value('Press 12')),
    );

    final updated = await studies.watchById(study.id).first;
    expect(updated.machineWorkstation, 'Press 12');
  });

  test('deleting a study leaves the project intact', () async {
    final projectId = await newProject();
    final study = await studies.create(
      projectId: projectId,
      name: 'Temp',
      type: StudyType.timeStudy,
    );

    await studies.delete(study.id);

    expect(await studies.watchByProject(projectId).first, isEmpty);
    expect(await projects.watchById(projectId).first, isNotNull);
  });
}
