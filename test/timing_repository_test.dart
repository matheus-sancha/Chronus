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

  // The lap key's rule (DESIGN.md §10.7). Pure, so the decision is tested
  // without a widget: this is the key an analyst presses blind, so what it does
  // in each state matters more than how it is wired.
  group('lap action (pure)', () {
    StudyOperation op(String id, double order) => StudyOperation(
          id: id,
          studyId: 's',
          orderIndex: order,
          name: id,
          category: OperationCategory.productive,
          isUnplanned: false,
          createdAt: DateTime(2026),
        );

    OperationTiming running() => OperationTiming(
        instance: _inst(), segments: [_seg(0, null)]);
    OperationTiming paused() =>
        OperationTiming(instance: _inst(), segments: [_seg(0, 100)]);
    OperationTiming done() => OperationTiming(
        instance: _inst(completed: DateTime(2026)), segments: [_seg(0, 100)]);
    OperationTiming pending() =>
        OperationTiming(instance: null, segments: const []);

    final a = op('a', 1), b = op('b', 2), c = op('c', 3);

    test('nothing running starts the first operation never timed', () {
      final action = lapActionFor(
        ops: [a, b, c],
        timing: {'a': done(), 'b': pending(), 'c': pending()},
      );
      expect(action, isA<LapStart>());
      expect((action as LapStart).studyOperationId, 'b');
    });

    test('one running advances from it', () {
      final action = lapActionFor(
        ops: [a, b, c],
        timing: {'a': done(), 'b': running(), 'c': pending()},
      );
      expect(action, isA<LapAdvance>());
      expect((action as LapAdvance).studyOperationId, 'b');
    });

    test('two running refuses rather than guessing', () {
      // The whole point: stopping the wrong operator's timer is unrecoverable,
      // so under concurrency the key does nothing at all.
      expect(
        lapActionFor(
          ops: [a, b, c],
          timing: {'a': running(), 'b': running(), 'c': pending()},
        ),
        isA<LapAmbiguous>(),
      );
    });

    test('a paused operation does not count as running', () {
      // Paused is not running, so the lap key moves on to fresh work rather than
      // resuming something the analyst deliberately stopped.
      final action = lapActionFor(
        ops: [a, b],
        timing: {'a': paused(), 'b': pending()},
      );
      expect(action, isA<LapStart>());
      expect((action as LapStart).studyOperationId, 'b');
    });

    test('paused and done are never restarted, so the run ends', () {
      expect(
        lapActionFor(ops: [a, b], timing: {'a': paused(), 'b': done()}),
        isA<LapNothing>(),
      );
    });

    test('an empty study has nothing to do', () {
      expect(lapActionFor(ops: const [], timing: const {}), isA<LapNothing>());
    });

    test('sequence order decides which operation starts, not map order', () {
      final action = lapActionFor(
        ops: [a, b, c],
        timing: {'c': pending(), 'b': pending(), 'a': done()},
      );
      expect((action as LapStart).studyOperationId, 'b');
    });
  });

  group('timing engine (db)', () {
    late AppDatabase db;
    late StudyOperationRepository sequence;
    late TimingRepository timing;
    late String studyId;
    late String obsId;
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
      // Every action below is scoped to a pass (DESIGN.md §11.1); the caller
      // resolves it once, which is exactly what the workspace does.
      obsId = await timing.ensureObservationId(studyId);
    });
    tearDown(() => db.close());

    Future<OperationTiming> timingOf(String studyOperationId) async {
      final instances = await timing.watchInstances(obsId).first;
      final segments = await timing.watchSegments(obsId).first;
      return timingByOperation(instances: instances, segments: segments)[
              studyOperationId] ??
          OperationTiming(instance: null, segments: const []);
    }

    test('ensureObservationId creates one pass and then only reads it',
        () async {
      // Called once per workspace, not once per action — so it has to be
      // idempotent, or a second press would collide on {studyId, sequenceIndex}.
      final again = await timing.ensureObservationId(studyId);
      expect(again, obsId);

      final all = await db.select(db.observations).get();
      expect(all.length, 1);
      expect(all.single.sequenceIndex, 0);
    });

    test('start opens a running segment, creating the instance lazily',
        () async {
      expect((await timing.watchInstances(obsId).first), isEmpty);
      await timing.start(observationId: obsId, studyOperationId: opA);

      expect((await timing.watchInstances(obsId).first).length, 1);
      expect((await timingOf(opA)).state, OperationTimingState.running);
    });

    test('pause preserves elapsed and stays resumable', () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.pause(observationId: obsId, studyOperationId: opA);

      final t = await timingOf(opA);
      expect(t.state, OperationTimingState.paused);
      expect(t.segments.length, 1);
      expect(t.segments.single.endAtMs, isNotNull); // closed
    });

    test('resume opens a second segment; time is the sum', () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.pause(observationId: obsId, studyOperationId: opA);
      await timing.start(observationId: obsId, studyOperationId: opA); // resume

      final t = await timingOf(opA);
      expect(t.state, OperationTimingState.running);
      expect(t.segments.length, 2);
      expect(t.segments.where((s) => s.endAtMs == null).length, 1);
    });

    test('stop marks the operation complete', () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.stop(observationId: obsId, studyOperationId: opA);

      final t = await timingOf(opA);
      expect(t.state, OperationTimingState.done);
      expect(t.instance!.completedAt, isNotNull);
      expect(t.segments.every((s) => s.endAtMs != null), isTrue);
    });

    test('reset zeroes segments and clears completion', () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.stop(observationId: obsId, studyOperationId: opA);
      await timing.reset(observationId: obsId, studyOperationId: opA);

      final t = await timingOf(opA);
      expect(t.segments, isEmpty);
      expect(t.state, OperationTimingState.pending);
    });

    test('two operations can run at the same time', () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.start(observationId: obsId, studyOperationId: opB);

      expect((await timingOf(opA)).state, OperationTimingState.running);
      expect((await timingOf(opB)).state, OperationTimingState.running);

      final segments = await timing.watchSegments(obsId).first;
      expect(segments.length, 2);
      expect(totalWallClockMs(segments), greaterThanOrEqualTo(0));
    });

    test('stopAndStartNext completes current and starts next, gapless', () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.stopAndStartNext(observationId: obsId, studyOperationId: opA);

      expect((await timingOf(opA)).state, OperationTimingState.done);
      expect((await timingOf(opB)).state, OperationTimingState.running);

      // Continuous: A's stop instant == B's start instant.
      final aEnd = (await timingOf(opA)).segments.single.endAtMs;
      final bStart = (await timingOf(opB)).segments.single.startAtMs;
      expect(aEnd, bStart);
    });

    test('stopAndStartNext on the last operation just stops', () async {
      await timing.start(observationId: obsId, studyOperationId: opC);
      await timing.stopAndStartNext(observationId: obsId, studyOperationId: opC);

      expect((await timingOf(opC)).state, OperationTimingState.done);
      final segments = await timing.watchSegments(obsId).first;
      expect(segments.where((s) => s.endAtMs == null), isEmpty); // nothing running
    });

    test('stopAndStartNext skips already-timed operations', () async {
      // B already done; advancing from A should land on C, not B.
      await timing.start(observationId: obsId, studyOperationId: opB);
      await timing.stop(observationId: obsId, studyOperationId: opB);

      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.stopAndStartNext(observationId: obsId, studyOperationId: opA);

      expect((await timingOf(opC)).state, OperationTimingState.running);
    });

    test('manual override shadows measured time without deleting segments',
        () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.stop(observationId: obsId, studyOperationId: opA);
      await timing.setManualActual(
          observationId: obsId, studyOperationId: opA, milliseconds: 12345);

      var t = await timingOf(opA);
      expect(t.actualMs(), 12345); // override in effect
      expect(t.segments, isNotEmpty); // segments preserved

      await timing.clearManualActual(observationId: obsId, studyOperationId: opA);
      t = await timingOf(opA);
      expect(t.manualActualMs, isNull); // falls back to measured
    });

    test('manual entry works with no live timing (paper transcription)',
        () async {
      await timing.setManualActual(
          observationId: obsId, studyOperationId: opC, milliseconds: 5000);
      final t = await timingOf(opC);
      expect(t.actualMs(), 5000);
      expect(t.segments, isEmpty);
      expect(t.isTimed, isTrue);
    });

    test('setNote stores a note (lazily) and blank clears it', () async {
      // Note on an operation that was never timed.
      await timing.setNote(
          observationId: obsId, studyOperationId: opA, note: '  chattering tool  ');
      expect((await timingOf(opA)).instance!.notes, 'chattering tool'); // trimmed

      await timing.setNote(observationId: obsId, studyOperationId: opA, note: '   ');
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

    test('discardRun clears the measurements but keeps the pass itself',
        () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await sequence.insertUnplannedAfter(
        studyId: studyId,
        afterStudyOperationId: opA,
        name: 'Waiting',
        category: OperationCategory.unproductive,
      );

      await timing.discardRun(obsId);

      // The pass survives with its sequenceIndex intact (DESIGN.md §11.1):
      // throwing away a run is not un-taking the pass, and renumbering would
      // make "Pass 4" in an exported file point somewhere else.
      final obs = await timing.watchObservation(studyId).first;
      expect(obs, isNotNull);
      expect(obs!.id, obsId);
      expect(await timing.watchInstances(obsId).first, isEmpty);
      expect(await timing.watchSegments(obsId).first, isEmpty);

      final ops = await sequence.watchByStudy(studyId).first;
      expect(ops.where((o) => o.isUnplanned), isEmpty);
      expect(ops.map((o) => o.name), ['A', 'B', 'C']);
    });

    // --- abandoned runs -----------------------------------------------------
    // An open segment keeps counting from its original start, which on Windows
    // means "closed the window and went home" reads as hours of measured work.

    test('orphanedTiming reports nothing when every segment is closed',
        () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.stop(observationId: obsId, studyOperationId: opA);
      await timing.start(observationId: obsId, studyOperationId: opB);
      await timing.pause(observationId: obsId, studyOperationId: opB);

      expect(await timing.orphanedTiming(), isNull);
    });

    test('orphanedTiming counts operations, not segments, and dates the oldest',
        () async {
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.pause(observationId: obsId, studyOperationId: opA);
      await timing.start(observationId: obsId, studyOperationId: opA); // 2nd open
      await timing.start(observationId: obsId, studyOperationId: opB);

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
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.pause(observationId: obsId, studyOperationId: opA);
      final measuredA = (await timingOf(opA)).measuredMs();
      await timing.start(observationId: obsId, studyOperationId: opA);
      // B: never stopped at all, and nothing else to fall back on.
      await timing.start(observationId: obsId, studyOperationId: opB);

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
      await timing.start(observationId: obsId, studyOperationId: opA);
      await timing.setManualActual(
        observationId: obsId,
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
