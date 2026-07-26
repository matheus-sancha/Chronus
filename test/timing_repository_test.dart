import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/features/projects/data/project_repository.dart';
import 'package:chronus/src/features/studies/data/study_operation_repository.dart';
import 'package:chronus/src/features/studies/data/study_repository.dart';
import 'package:chronus/src/features/studies/data/timing_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// --- pure time-math helpers (deterministic; no clock) -----------------------

OperationTimeSegment _seg(int start, int? end) => OperationTimeSegment(
      id: 's$start',
      operationInstanceId: 'i',
      startAtMs: start,
      endAtMs: end,
      createdAt: DateTime(2020),
    );

OperationInstance _inst({int? manual, DateTime? completed}) => OperationInstance(
      id: 'i',
      observationId: 'o',
      studyOperationId: 's',
      manualActualMs: manual,
      completedAt: completed,
      notes: null,
      createdAt: DateTime(2020),
    );

void main() {
  group('timing model (pure)', () {
    test('measuredMs sums segment durations', () {
      final t =
          OperationTiming(instance: null, segments: [_seg(0, 100), _seg(200, 350)]);
      expect(t.measuredMs(99999), 250);
    });

    test('an open segment counts up to now', () {
      final t = OperationTiming(instance: null, segments: [_seg(100, null)]);
      expect(t.measuredMs(400), 300);
    });

    test('manual override shadows the measured sum, segments preserved', () {
      final t = OperationTiming(
          instance: _inst(manual: 42), segments: [_seg(0, 100)]);
      expect(t.actualMs(99999), 42); // override wins
      expect(t.measuredMs(99999), 100); // measured still available
    });

    test('actualMs is null only when untimed', () {
      expect(OperationTiming(instance: null, segments: const []).actualMs(0),
          isNull);
      expect(
          OperationTiming(instance: _inst(manual: 7), segments: const [])
              .actualMs(0),
          7);
    });

    test('total study time is the wall-clock span, not the sum of overlap', () {
      // op A 0..500 overlaps op B 100..300 → span 500, not sum 700.
      expect(totalWallClockMs([_seg(0, 500), _seg(100, 300)]), 500);
      expect(totalWallClockMs(const []), 0);
    });

    test('lifecycle state', () {
      expect(OperationTiming(instance: null, segments: const []).state,
          OperationTimingState.pending);
      expect(
          OperationTiming(instance: _inst(), segments: [_seg(0, null)]).state,
          OperationTimingState.running);
      expect(OperationTiming(instance: _inst(), segments: [_seg(0, 100)]).state,
          OperationTimingState.paused);
      expect(
          OperationTiming(
                  instance: _inst(completed: DateTime(2021)),
                  segments: [_seg(0, 100)])
              .state,
          OperationTimingState.done);
      expect(
          OperationTiming(instance: _inst(manual: 50), segments: const []).state,
          OperationTimingState.done);
    });
  });

  group('timing engine (db)', () {
    late AppDatabase db;
    late StudyOperationRepository sequence;
    late TimingRepository timing;
    late String studyId;
    late String opA, opB, opC;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      sequence = StudyOperationRepository(db);
      timing = TimingRepository(db);
      final project = await ProjectRepository(db).create(name: 'P');
      final study = await StudyRepository(db).create(
        projectId: project.id,
        name: 'S',
        type: StudyType.timeStudy,
      );
      studyId = study.id;
      for (final name in ['A', 'B', 'C']) {
        await sequence.addCustom(
          studyId: studyId,
          name: name,
          category: OperationCategory.productive,
        );
      }
      final ops = await sequence.watchByStudy(studyId).first;
      opA = ops[0].id;
      opB = ops[1].id;
      opC = ops[2].id;
    });
    tearDown(() => db.close());

    Future<OperationTiming> timingOf(String studyOperationId) async {
      final obs = await timing.watchObservation(studyId).first;
      if (obs == null) {
        return OperationTiming(instance: null, segments: const []);
      }
      final instances = await timing.watchInstances(obs.id).first;
      final segments = await timing.watchSegments(obs.id).first;
      return timingByOperation(instances: instances, segments: segments)[
              studyOperationId] ??
          OperationTiming(instance: null, segments: const []);
    }

    test('start opens a running segment (lazy observation + instance)',
        () async {
      expect(await timing.watchObservation(studyId).first, isNull);
      await timing.start(studyId: studyId, studyOperationId: opA);

      expect(await timing.watchObservation(studyId).first, isNotNull);
      expect((await timingOf(opA)).state, OperationTimingState.running);
    });

    test('pause preserves elapsed and stays resumable', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.pause(studyId: studyId, studyOperationId: opA);

      final t = await timingOf(opA);
      expect(t.state, OperationTimingState.paused);
      expect(t.segments.length, 1);
      expect(t.segments.single.endAtMs, isNotNull); // closed
    });

    test('resume opens a second segment; time is the sum', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.pause(studyId: studyId, studyOperationId: opA);
      await timing.start(studyId: studyId, studyOperationId: opA); // resume

      final t = await timingOf(opA);
      expect(t.state, OperationTimingState.running);
      expect(t.segments.length, 2);
      expect(t.segments.where((s) => s.endAtMs == null).length, 1);
    });

    test('stop marks the operation complete', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.stop(studyId: studyId, studyOperationId: opA);

      final t = await timingOf(opA);
      expect(t.state, OperationTimingState.done);
      expect(t.instance!.completedAt, isNotNull);
      expect(t.segments.every((s) => s.endAtMs != null), isTrue);
    });

    test('reset zeroes segments and clears completion', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.stop(studyId: studyId, studyOperationId: opA);
      await timing.reset(studyId: studyId, studyOperationId: opA);

      final t = await timingOf(opA);
      expect(t.segments, isEmpty);
      expect(t.state, OperationTimingState.pending);
    });

    test('two operations can run at the same time', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.start(studyId: studyId, studyOperationId: opB);

      expect((await timingOf(opA)).state, OperationTimingState.running);
      expect((await timingOf(opB)).state, OperationTimingState.running);

      final obs = await timing.watchObservation(studyId).first;
      final segments = await timing.watchSegments(obs!.id).first;
      expect(segments.length, 2);
      expect(totalWallClockMs(segments), greaterThanOrEqualTo(0));
    });

    test('stopAndStartNext completes current and starts next, gapless', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.stopAndStartNext(studyId: studyId, studyOperationId: opA);

      expect((await timingOf(opA)).state, OperationTimingState.done);
      expect((await timingOf(opB)).state, OperationTimingState.running);

      // Continuous: A's stop instant == B's start instant.
      final aEnd = (await timingOf(opA)).segments.single.endAtMs;
      final bStart = (await timingOf(opB)).segments.single.startAtMs;
      expect(aEnd, bStart);
    });

    test('stopAndStartNext on the last operation just stops', () async {
      await timing.start(studyId: studyId, studyOperationId: opC);
      await timing.stopAndStartNext(studyId: studyId, studyOperationId: opC);

      expect((await timingOf(opC)).state, OperationTimingState.done);
      final obs = await timing.watchObservation(studyId).first;
      final segments = await timing.watchSegments(obs!.id).first;
      expect(segments.where((s) => s.endAtMs == null), isEmpty); // nothing running
    });

    test('stopAndStartNext skips already-timed operations', () async {
      // B already done; advancing from A should land on C, not B.
      await timing.start(studyId: studyId, studyOperationId: opB);
      await timing.stop(studyId: studyId, studyOperationId: opB);

      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.stopAndStartNext(studyId: studyId, studyOperationId: opA);

      expect((await timingOf(opC)).state, OperationTimingState.running);
    });

    test('manual override shadows measured time without deleting segments',
        () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.stop(studyId: studyId, studyOperationId: opA);
      await timing.setManualActual(
          studyId: studyId, studyOperationId: opA, milliseconds: 12345);

      var t = await timingOf(opA);
      expect(t.actualMs(), 12345); // override in effect
      expect(t.segments, isNotEmpty); // segments preserved

      await timing.clearManualActual(studyId: studyId, studyOperationId: opA);
      t = await timingOf(opA);
      expect(t.manualActualMs, isNull); // falls back to measured
    });

    test('manual entry works with no live timing (paper transcription)',
        () async {
      await timing.setManualActual(
          studyId: studyId, studyOperationId: opC, milliseconds: 5000);
      final t = await timingOf(opC);
      expect(t.actualMs(), 5000);
      expect(t.segments, isEmpty);
      expect(t.isTimed, isTrue);
    });

    test('setNote stores a note (lazily) and blank clears it', () async {
      // Note on an operation that was never timed.
      await timing.setNote(
          studyId: studyId, studyOperationId: opA, note: '  chattering tool  ');
      expect((await timingOf(opA)).instance!.notes, 'chattering tool'); // trimmed

      await timing.setNote(studyId: studyId, studyOperationId: opA, note: '   ');
      expect((await timingOf(opA)).instance!.notes, null); // blank clears
    });

    test('insertUnplannedAfter places the op between its neighbours', () async {
      final ins = await sequence.insertUnplannedAfter(
        studyId: studyId,
        afterStudyOperationId: opA,
        name: 'Waiting',
        category: OperationCategory.unproductive,
      );
      expect(ins.isUnplanned, isTrue);
      expect(ins.orderIndex, greaterThan(1.0));
      expect(ins.orderIndex, lessThan(2.0)); // between A(1) and B(2)
    });

    test('discardRun removes the run and its unplanned ops, keeps planned',
        () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await sequence.insertUnplannedAfter(
        studyId: studyId,
        afterStudyOperationId: opA,
        name: 'Waiting',
        category: OperationCategory.unproductive,
      );

      await timing.discardRun(studyId);

      expect(await timing.watchObservation(studyId).first, isNull);
      final ops = await sequence.watchByStudy(studyId).first;
      expect(ops.where((o) => o.isUnplanned), isEmpty);
      expect(ops.map((o) => o.name), ['A', 'B', 'C']);
    });

    // --- abandoned runs -----------------------------------------------------
    // An open segment keeps counting from its original start, which on Windows
    // means "closed the window and went home" reads as hours of measured work.

    test('orphanedTiming reports nothing when every segment is closed',
        () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.stop(studyId: studyId, studyOperationId: opA);
      await timing.start(studyId: studyId, studyOperationId: opB);
      await timing.pause(studyId: studyId, studyOperationId: opB);

      expect(await timing.orphanedTiming(), isNull);
    });

    test('orphanedTiming counts operations, not segments, and dates the oldest',
        () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.pause(studyId: studyId, studyOperationId: opA);
      await timing.start(studyId: studyId, studyOperationId: opA); // 2nd open
      await timing.start(studyId: studyId, studyOperationId: opB);

      final orphaned = await timing.orphanedTiming();
      expect(orphaned, isNotNull);
      // A has two segments but is one thing the analyst forgot to stop.
      expect(orphaned!.operations, 2);
      expect(
        orphaned.since.isAfter(DateTime.now().subtract(const Duration(minutes: 1))),
        isTrue,
      );
    });

    test('discarding drops only open segments, keeping what was measured',
        () async {
      // A: one measured interval, then resumed and abandoned.
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.pause(studyId: studyId, studyOperationId: opA);
      final measuredA = (await timingOf(opA)).measuredMs();
      await timing.start(studyId: studyId, studyOperationId: opA);
      // B: never stopped at all, and nothing else to fall back on.
      await timing.start(studyId: studyId, studyOperationId: opB);

      await timing.discardOrphanedTiming();

      final a = await timingOf(opA);
      expect(a.state, OperationTimingState.paused);
      expect(a.measuredMs(), measuredA); // the fabricated tail is gone
      // B loses its only segment and goes back to being untimed, so the analyst
      // re-times it or enters a manual override rather than trusting a fiction.
      final b = await timingOf(opB);
      expect(b.state, OperationTimingState.pending);
      expect(b.actualMs(), isNull);
      expect(await timing.orphanedTiming(), isNull);
    });

    test('discarding leaves a manual override untouched', () async {
      await timing.start(studyId: studyId, studyOperationId: opA);
      await timing.setManualActual(
        studyId: studyId,
        studyOperationId: opA,
        milliseconds: 42000,
      );

      await timing.discardOrphanedTiming();

      final a = await timingOf(opA);
      expect(a.actualMs(), 42000);
      expect(a.segments, isEmpty);
    });
  });
}
