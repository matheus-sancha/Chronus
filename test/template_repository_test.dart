import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/catalog/data/catalog_repository.dart';
import 'package:chronus/src/features/projects/data/project_repository.dart';
import 'package:chronus/src/features/studies/data/study_operation_repository.dart';
import 'package:chronus/src/features/templates/data/template_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;
  late TemplateRepository templates;
  late ProjectRepository projects;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = CatalogRepository(db);
    templates = TemplateRepository(db);
    projects = ProjectRepository(db);
  });
  tearDown(() => db.close());

  Future<Template> templateWithOps(List<String> names) async {
    final template = await templates.create(
      name: 'Line 3 cycle',
      defaultStudyType: StudyType.samplingStudy,
      defaultAllowancePercent: 10,
    );
    for (final name in names) {
      final op = await catalog.create(
        name: name,
        category: OperationCategory.productive,
        referenceStandardMs: 4000,
      );
      await templates.addOperation(
        templateId: template.id,
        catalogOperationId: op.id,
      );
    }
    return template;
  }

  test('create and add operations keeps order', () async {
    final template = await templateWithOps(['A', 'B', 'C']);
    final ops = await templates.watchOperations(template.id).first;
    expect(ops, hasLength(3));
    expect(ops.map((o) => o.orderIndex), [1.0, 2.0, 3.0]);
  });

  test('instantiate creates a study with snapshotted operations', () async {
    final template = await templateWithOps(['A', 'B']);
    final project = await projects.create(name: 'P');

    final study = await templates.instantiate(
      templateId: template.id,
      projectId: project.id,
      name: 'Run 1',
    );

    expect(study.type, StudyType.samplingStudy); // from template
    expect(study.allowancePercent, 10);

    final ops = await StudyOperationRepository(db).watchByStudy(study.id).first;
    expect(ops.map((o) => o.name), ['A', 'B']);
    expect(ops.first.referenceStandardMs, 4000);
    expect(ops.first.catalogOperationId, isNotNull); // keeps the link
  });

  test('save study as template keeps catalog ops, skips custom', () async {
    final project = await projects.create(name: 'P');
    final study = await StudyRepositoryStub(db).create(project.id);
    final seq = StudyOperationRepository(db);
    final op = await catalog.create(
      name: 'Cataloged',
      category: OperationCategory.productive,
    );
    await seq.addFromCatalog(studyId: study, operation: op);
    await seq.addCustom(
      studyId: study,
      name: 'Ad-hoc',
      category: OperationCategory.unproductive,
    );

    final template = await templates.saveStudyAsTemplate(
      studyId: study,
      name: 'From study',
    );

    final ops = await templates.watchOperations(template.id).first;
    expect(ops, hasLength(1)); // only the catalog-backed op
    expect(ops.single.catalogOperationId, op.id);
  });

  test('deleting a template removes its operation links', () async {
    final template = await templateWithOps(['A']);
    await templates.delete(template.id);
    expect(await templates.watchOperations(template.id).first, isEmpty);
  });
}

/// Small helper to create a study without importing the studies test file.
class StudyRepositoryStub {
  StudyRepositoryStub(this._db);
  final AppDatabase _db;

  Future<String> create(String projectId) async {
    final now = DateTime.now();
    const id = 'study-under-test';
    await _db.into(_db.studies).insert(
          StudiesCompanion.insert(
            id: id,
            projectId: projectId,
            type: StudyType.timeStudy,
            name: 'S',
            performedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }
}
