import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/projects/data/project_repository.dart';
import 'package:chronus/src/features/studies/data/observation_repository.dart';
import 'package:chronus/src/features/studies/data/study_operation_repository.dart';
import 'package:chronus/src/features/studies/data/study_repository.dart';
import 'package:chronus/src/features/studies/data/timing_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ObservationRepository passes;
  late StudyOperationRepository sequence;
  late TimingRepository timing;
  late String studyId;
  late String opA, opB;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    passes = ObservationRepository(db);
    sequence = StudyOperationRepository(db);
    timing = TimingRepository(db);
    final project = await ProjectRepository(db).create(name: 'P');
    final study = await StudyRepository(db).create(
      projectId: project.id,
      name: 'S',
      type: StudyType.samplingStudy,
    );
    studyId = study.id;
    for (final name in ['A', 'B']) {
      await sequence.addCustom(
        studyId: studyId,
        name: name,
        category: OperationCategory.productive,
      );
    }
    final ops = await sequence.watchByStudy(studyId).first;
    opA = ops[0].id;
    opB = ops[1].id;
  });
  tearDown(() => db.close());

  test('a study is created with pass 1 already open', () async {
    // The invariant everything downstream drops its null branch for (§11.1).
    final all = await passes.watchPasses(studyId).first;
    expect(all, hasLength(1));
    expect(all.single.number, 1);
    expect(all.single.observation.sequenceIndex, 0);
    expect(all.single.isEmpty, isTrue);
  });

  test('pass completeness counts operations carrying a time, not instances',
      () async {
    final first = (await passes.watchPasses(studyId).first).single;
    // A note creates an instance with no time in it; the pass is still empty.
    await timing.setNote(
        observationId: first.id, studyOperationId: opA, note: 'scratch');
    expect((await passes.watchPasses(studyId).first).single.timedOperations, 0);

    await timing.start(observationId: first.id, studyOperationId: opA);
    await timing.stop(observationId: first.id, studyOperationId: opA);
    // A typed override counts too — it is a reported time (§11.4).
    await timing.setManualActual(
        observationId: first.id, studyOperationId: opB, milliseconds: 5000);

    final summary = (await passes.watchPasses(studyId).first).single;
    expect(summary.timedOperations, 2);
    expect(summary.totalOperations, 2);
    expect(summary.isComplete, isTrue);
  });

  test('addPass numbers from the highest ever used, never reusing one',
      () async {
    final second = await passes.addPass(studyId);
    final third = await passes.addPass(studyId);
    expect(second.sequenceIndex, 1);
    expect(third.sequenceIndex, 2);

    // Delete the last one and add another: the number must not come back, or an
    // export naming "Pass 3" would point at different measurements (§11.3).
    expect(await passes.deleteIfEmpty(third.id), isTrue);
    final fourth = await passes.addPass(studyId);
    expect(fourth.sequenceIndex, 3);

    final numbers =
        (await passes.watchPasses(studyId).first).map((p) => p.number);
    expect(numbers, [1, 2, 4]); // the gap is deliberate and stays
  });

  test('excluding a pass keeps its measurements and is reversible', () async {
    final first = (await passes.watchPasses(studyId).first).single;
    await timing.start(observationId: first.id, studyOperationId: opA);
    await timing.stop(observationId: first.id, studyOperationId: opA);

    await passes.setExcluded(first.id, excluded: true, reason: '  line starved ');
    var summary = (await passes.watchPasses(studyId).first).single;
    expect(summary.isExcluded, isTrue);
    expect(summary.observation.exclusionReason, 'line starved'); // trimmed
    // Excluded is not deleted: the pass still holds what it measured.
    expect(summary.timedOperations, 1);

    await passes.setExcluded(first.id, excluded: false);
    summary = (await passes.watchPasses(studyId).first).single;
    expect(summary.isExcluded, isFalse);
    expect(summary.observation.exclusionReason, isNull);
  });

  test('a pass holding measurements cannot be deleted', () async {
    final first = (await passes.watchPasses(studyId).first).single;
    final second = await passes.addPass(studyId);
    await timing.start(observationId: second.id, studyOperationId: opA);

    // Measured time: exclusion is the tool, not deletion (§11.3).
    expect(await passes.deleteIfEmpty(second.id), isFalse);
    expect(await passes.watchPasses(studyId).first, hasLength(2));

    // A typed override is a measurement too, for this purpose.
    final third = await passes.addPass(studyId);
    await timing.setManualActual(
        observationId: third.id, studyOperationId: opB, milliseconds: 1000);
    expect(await passes.deleteIfEmpty(third.id), isFalse);

    // ...and an empty one still goes.
    final fourth = await passes.addPass(studyId);
    expect(await passes.deleteIfEmpty(fourth.id), isTrue);
    expect(first.id, isNotNull);
  });

  test('the last remaining pass cannot be deleted even when empty', () async {
    // Otherwise a study could end up with none, which is the invariant §11.1
    // exists to hold — and the guard lives in the repository so no second
    // caller can route around it.
    final only = (await passes.watchPasses(studyId).first).single;
    expect(only.isEmpty, isTrue);
    expect(await passes.deleteIfEmpty(only.id), isFalse);
    expect(await passes.watchPasses(studyId).first, hasLength(1));
  });

  test('deleting a pass leaves the other passes untouched', () async {
    final first = (await passes.watchPasses(studyId).first).single;
    await timing.start(observationId: first.id, studyOperationId: opA);
    await timing.stop(observationId: first.id, studyOperationId: opA);
    final measured = (await timing.watchSegments(first.id).first).length;

    final spare = await passes.addPass(studyId);
    expect(await passes.deleteIfEmpty(spare.id), isTrue);

    expect((await timing.watchSegments(first.id).first).length, measured);
    expect((await passes.watchPasses(studyId).first).single.id, first.id);
  });
}
