import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:flutter_test/flutter_test.dart';

StudyOperation _op(String id, {int? reference}) => StudyOperation(
      id: id,
      studyId: 's',
      catalogOperationId: null,
      orderIndex: 1,
      name: id,
      category: OperationCategory.productive,
      subtypeId: null,
      referenceStandardMs: reference,
      isUnplanned: false,
      createdAt: DateTime(2026),
    );

OperationTiming _timing({int? manualMs, List<(int, int?)> segments = const []}) {
  return OperationTiming(
    instance: OperationInstance(
      id: 'i',
      observationId: 'o',
      studyOperationId: 'op',
      manualActualMs: manualMs,
      completedAt: null,
      notes: null,
      createdAt: DateTime(2026),
    ),
    segments: [
      for (final (start, end) in segments)
        OperationTimeSegment(
          id: 'g$start',
          operationInstanceId: 'i',
          startAtMs: start,
          endAtMs: end,
          createdAt: DateTime(2026),
        ),
    ],
  );
}

void main() {
  group('alert window', () {
    test('is a tenth of the reference standard, capped at 30s', () {
      expect(alertWindowMs(10000), 1000); // 10s op -> 1s
      expect(alertWindowMs(30000), 3000); // 30s op -> 3s
      expect(alertWindowMs(300000), 30000); // 5m op -> 30s, at the cap
      expect(alertWindowMs(7200000), 30000); // 2h op -> still 30s
    });

    test('never exceeds the operation, so it cannot precede the start', () {
      // The whole point of the 30s being a cap rather than a floor: as a floor,
      // every one of these would warn at or before t=0.
      for (final reference in [1000, 5000, 8000, 20000, 30000]) {
        expect(alertWindowMs(reference), lessThan(reference),
            reason: 'window must leave room to run for a ${reference}ms op');
      }
    });
  });

  group('paceFor', () {
    test('crosses to approaching at exactly one window before the standard',
        () {
      // 5m standard -> 30s window -> approaching from 4:30.
      expect(paceFor(elapsedMs: 269999, referenceStandardMs: 300000),
          OperationPace.onTrack);
      expect(paceFor(elapsedMs: 270000, referenceStandardMs: 300000),
          OperationPace.approaching);
    });

    test('crosses to over at the standard, and stays over', () {
      expect(paceFor(elapsedMs: 299999, referenceStandardMs: 300000),
          OperationPace.approaching);
      expect(paceFor(elapsedMs: 300000, referenceStandardMs: 300000),
          OperationPace.over);
      expect(paceFor(elapsedMs: 900000, referenceStandardMs: 300000),
          OperationPace.over);
    });

    test('short operations still get a warning phase before the standard', () {
      // 10s standard -> 1s window -> approaching from 9s. Nothing fires at t=0.
      expect(paceFor(elapsedMs: 0, referenceStandardMs: 10000),
          OperationPace.onTrack);
      expect(paceFor(elapsedMs: 8999, referenceStandardMs: 10000),
          OperationPace.onTrack);
      expect(paceFor(elapsedMs: 9000, referenceStandardMs: 10000),
          OperationPace.approaching);
    });

    test('is null when the comparison does not apply', () {
      // No reference standard, nothing timed, or a nonsense standard: these are
      // "not applicable", never "on track" — the UI must show no colour and
      // play no sound rather than imply the operation is doing fine.
      expect(paceFor(elapsedMs: 5000, referenceStandardMs: null), isNull);
      expect(paceFor(elapsedMs: null, referenceStandardMs: 5000), isNull);
      expect(paceFor(elapsedMs: 5000, referenceStandardMs: 0), isNull);
    });

    test('severity ordering backs the alert latch', () {
      expect(OperationPace.over.index,
          greaterThan(OperationPace.approaching.index));
      expect(OperationPace.approaching.index,
          greaterThan(OperationPace.onTrack.index));
    });
  });

  group('header totals', () {
    test('work content sums operations, counting overlap twice', () {
      // Two operations running over the same wall-clock second. The span is 1s
      // but the work content is 2s — that is the point of reporting both.
      final a = _timing(segments: [(0, 1000)]);
      final b = _timing(segments: [(0, 1000)]);
      expect(workContentMs([a, b]), 2000);
    });

    test('work content honours a manual override', () {
      final t = _timing(manualMs: 9000, segments: [(0, 1000)]);
      expect(workContentMs([t]), 9000);
    });

    test('work content ignores untimed operations', () {
      expect(workContentMs([_timing(), _timing(segments: [(0, 1000)])]), 1000);
    });

    test('expected sums every operation and reports coverage', () {
      final total = expectedTotal([
        _op('a', reference: 60000),
        _op('b', reference: 30000),
        _op('c'), // no benchmark
      ]);
      expect(total.totalMs, 90000);
      expect(total.withReference, 2);
      expect(total.total, 3);
    });

    test('expected is zero with no references at all', () {
      final total = expectedTotal([_op('a'), _op('b')]);
      expect(total.totalMs, 0);
      expect(total.withReference, 0);
      expect(total.total, 2);
    });

    test('expected does not move as operations are timed', () {
      // Expected is the plan, so it must be a fixed target during a run. It is
      // computed from the sequence alone and never sees timing.
      final ops = [_op('a', reference: 60000), _op('b', reference: 30000)];
      expect(expectedTotal(ops).totalMs, 90000);
      expect(expectedTotal(ops).totalMs, 90000);
    });
  });
}
