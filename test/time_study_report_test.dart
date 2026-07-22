import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:flutter_test/flutter_test.dart';

StudyOperation _op(String id, OperationCategory cat, double order,
        {String? subtypeId, int? reference}) =>
    StudyOperation(
      id: id,
      studyId: 's',
      catalogOperationId: null,
      orderIndex: order,
      name: id,
      category: cat,
      subtypeId: subtypeId,
      referenceStandardMs: reference,
      isUnplanned: false,
      createdAt: DateTime(2026),
    );

OperationInstance _inst(String opId) => OperationInstance(
      id: 'i$opId',
      observationId: 'o',
      studyOperationId: opId,
      manualActualMs: null,
      completedAt: DateTime(2026),
      notes: null,
      createdAt: DateTime(2026),
    );

OperationTimeSegment _seg(String opId, int start, int end) =>
    OperationTimeSegment(
      id: 'g$opId',
      operationInstanceId: 'i$opId',
      startAtMs: start,
      endAtMs: end,
      createdAt: DateTime(2026),
    );

void main() {
  test('report computes efficiency, roll-ups, timeline and elapsed', () {
    final subtype = OperationSubtype(
      id: 'w',
      category: OperationCategory.unproductive,
      name: 'Waiting',
      isBuiltIn: true,
      createdAt: DateTime(2026),
    );

    // P (productive) 0..10000, reference 8000 → efficiency 80%.
    // W (waste) 5000..9000 (inside P), no reference.
    final segP = _seg('P', 0, 10000);
    final segW = _seg('W', 5000, 9000);

    final report = buildTimeStudyReport(
      operations: [
        _op('P', OperationCategory.productive, 1, reference: 8000),
        _op('W', OperationCategory.unproductive, 2, subtypeId: 'w'),
      ],
      timing: {
        'P': OperationTiming(instance: _inst('P'), segments: [segP]),
        'W': OperationTiming(instance: _inst('W'), segments: [segW]),
      },
      subtypeById: {'w': subtype},
      segments: [segP, segW],
    );

    // Work content = 10000 + 4000; elapsed = span 0..10000.
    expect(report.totalWorkContentMs, 14000);
    expect(report.totalElapsedMs, 10000);
    expect(report.valueAddedRatio, closeTo(10000 / 14000, 1e-9));

    // Efficiency: aggregate over ops with a reference = 8000 / 10000 = 0.8.
    expect(report.efficiency, closeTo(0.8, 1e-9));
    final pRow = report.rows.firstWhere((r) => r.operation.id == 'P');
    final wRow = report.rows.firstWhere((r) => r.operation.id == 'W');
    expect(pRow.efficiency, closeTo(0.8, 1e-9)); // 8000 / 10000
    expect(wRow.efficiency, isNull); // no reference

    // Timeline in planned-sequence order, on real timestamps.
    expect(report.timeline.map((t) => t.operation.id), ['P', 'W']);
    expect(report.timelineHasClock, isTrue);
    expect(report.timelineStartMs, 0);
    expect(report.timelineEndMs, 10000);

    // W (5000..9000) sits entirely inside P (0..10000): 4000 ms of overlap,
    // and no unattributed time because P covers the whole span.
    expect(report.simultaneousMs, 4000);
    expect(report.unattributedMs, 0);

    // Pareto has the single waste subtype.
    expect(report.wastePareto.single.subtype?.name, 'Waiting');
    expect(report.wastePareto.single.ms, 4000);
  });

  group('simultaneous & unattributed', () {
    test('gaps do not make simultaneity negative (the naive-formula trap)', () {
      // Two 10 s operations with a 5 s gap and NO overlap. work - elapsed
      // would be 20000 - 25000 = -5000; the sweep must say 0 overlap and
      // 5000 ms unattributed.
      final a = _seg('A', 0, 10000);
      final b = _seg('B', 15000, 25000);

      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2),
        ],
        timing: {
          'A': OperationTiming(instance: _inst('A'), segments: [a]),
          'B': OperationTiming(instance: _inst('B'), segments: [b]),
        },
        subtypeById: const {},
        segments: [a, b],
      );

      expect(report.totalWorkContentMs, 20000);
      expect(report.totalElapsedMs, 25000);
      expect(report.simultaneousMs, 0);
      expect(report.unattributedMs, 5000);
    });

    test('touching intervals are not counted as overlapping', () {
      final a = _seg('A', 0, 10000);
      final b = _seg('B', 10000, 20000);

      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2),
        ],
        timing: {
          'A': OperationTiming(instance: _inst('A'), segments: [a]),
          'B': OperationTiming(instance: _inst('B'), segments: [b]),
        },
        subtypeById: const {},
        segments: [a, b],
      );

      expect(report.simultaneousMs, 0);
      expect(report.unattributedMs, 0);
    });

    test('three-deep overlap is counted once, not per pair', () {
      // A 0..30, B 10..30, C 10..30 → 20 s where 2+ run at once.
      final a = _seg('A', 0, 30000);
      final b = _seg('B', 10000, 30000);
      final c = _seg('C', 10000, 30000);

      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2),
          _op('C', OperationCategory.productive, 3),
        ],
        timing: {
          'A': OperationTiming(instance: _inst('A'), segments: [a]),
          'B': OperationTiming(instance: _inst('B'), segments: [b]),
          'C': OperationTiming(instance: _inst('C'), segments: [c]),
        },
        subtypeById: const {},
        segments: [a, b, c],
      );

      expect(report.simultaneousMs, 20000);
    });
  });

  group('timeline rows', () {
    test('rows follow planned sequence even when timed out of order', () {
      // B is sequenced second but ran first.
      final a = _seg('A', 10000, 20000);
      final b = _seg('B', 0, 5000);

      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2),
        ],
        timing: {
          'A': OperationTiming(instance: _inst('A'), segments: [a]),
          'B': OperationTiming(instance: _inst('B'), segments: [b]),
        },
        subtypeById: const {},
        segments: [a, b],
      );

      expect(report.timeline.map((r) => r.operation.id), ['A', 'B']);
      // ...but the bar positions still tell the truth.
      expect(report.timeline[0].startMs, 10000);
      expect(report.timeline[1].startMs, 0);
    });

    test('pause/resume becomes two blocks with the gap between them', () {
      final first = _seg('A', 0, 5000);
      final second = OperationTimeSegment(
        id: 'gA2',
        operationInstanceId: 'iA',
        startAtMs: 8000,
        endAtMs: 12000,
        createdAt: DateTime(2026),
      );

      final report = buildTimeStudyReport(
        operations: [_op('A', OperationCategory.productive, 1)],
        timing: {
          'A': OperationTiming(
              instance: _inst('A'), segments: [first, second]),
        },
        subtypeById: const {},
        segments: [first, second],
      );

      final row = report.timeline.single;
      expect(row.blocks.length, 2);
      expect(row.blocks.every((b) => b.measured), isTrue);
      // Ink equals observed time (9000), not the 12000 span.
      expect(row.blocks.fold(0, (s, b) => s + b.durationMs), 9000);
      expect(row.startMs, 0);
      expect(row.endMs, 12000);
    });
  });

  group('manual override', () {
    OperationInstance overridden(String opId, int manualMs) => OperationInstance(
          id: 'i$opId',
          observationId: 'o',
          studyOperationId: opId,
          manualActualMs: manualMs,
          completedAt: DateTime(2026),
          notes: null,
          createdAt: DateTime(2026),
        );

    test('longer than measured extends with an unmeasured block', () {
      // Forgot to start the timer: measured 5 s, reported 20 s.
      final seg = _seg('A', 0, 5000);
      final report = buildTimeStudyReport(
        operations: [_op('A', OperationCategory.productive, 1)],
        timing: {
          'A': OperationTiming(
              instance: overridden('A', 20000), segments: [seg]),
        },
        subtypeById: const {},
        segments: [seg],
      );

      final row = report.timeline.single;
      expect(row.blocks.length, 2);
      expect(row.blocks[0].measured, isTrue);
      expect(row.blocks[0].durationMs, 5000);
      expect(row.blocks[1].measured, isFalse);
      expect(row.blocks[1].durationMs, 15000);
      // Total width matches the reported number, so chart and table agree.
      expect(row.blocks.fold(0, (s, b) => s + b.durationMs), 20000);

      // The fabricated tail must not manufacture concurrency.
      expect(report.simultaneousMs, 0);
    });

    test('shorter than measured trims from the end', () {
      final seg = _seg('A', 0, 10000);
      final report = buildTimeStudyReport(
        operations: [_op('A', OperationCategory.productive, 1)],
        timing: {
          'A': OperationTiming(
              instance: overridden('A', 4000), segments: [seg]),
        },
        subtypeById: const {},
        segments: [seg],
      );

      final row = report.timeline.single;
      expect(row.blocks.single.measured, isTrue);
      expect(row.blocks.single.durationMs, 4000);
      expect(row.endMs, 4000);
    });
  });

  group('studies with no live timing', () {
    test('a paper study gets a relative axis, never a fabricated clock', () {
      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2),
        ],
        timing: {
          'A': OperationTiming(
              instance: OperationInstance(
                id: 'iA',
                observationId: 'o',
                studyOperationId: 'A',
                manualActualMs: 6000,
                completedAt: DateTime(2026),
                notes: null,
                createdAt: DateTime(2026),
              ),
              segments: const []),
          'B': OperationTiming(
              instance: OperationInstance(
                id: 'iB',
                observationId: 'o',
                studyOperationId: 'B',
                manualActualMs: 4000,
                completedAt: DateTime(2026),
                notes: null,
                createdAt: DateTime(2026),
              ),
              segments: const []),
        },
        subtypeById: const {},
        segments: const [],
      );

      expect(report.timelineHasClock, isFalse);
      expect(report.timelineStartMs, 0);
      // Laid out end to end from zero, in sequence order.
      expect(report.timeline[0].startMs, 0);
      expect(report.timeline[0].endMs, 6000);
      expect(report.timeline[1].startMs, 6000);
      expect(report.timeline[1].endMs, 10000);
      expect(report.timeline.every((r) => !r.hasMeasured), isTrue);
      // Nothing was measured, so there is nothing to call simultaneous.
      expect(report.simultaneousMs, 0);
    });

    test('untimed operations are appended after the last real timestamp', () {
      final seg = _seg('A', 1000, 6000);
      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2),
        ],
        timing: {
          'A': OperationTiming(instance: _inst('A'), segments: [seg]),
          'B': OperationTiming(
              instance: OperationInstance(
                id: 'iB',
                observationId: 'o',
                studyOperationId: 'B',
                manualActualMs: 3000,
                completedAt: DateTime(2026),
                notes: null,
                createdAt: DateTime(2026),
              ),
              segments: const []),
        },
        subtypeById: const {},
        segments: [seg],
      );

      expect(report.timelineHasClock, isTrue);
      expect(report.timeline[1].startMs, 6000); // after A's last timestamp
      expect(report.timeline[1].blocks.single.measured, isFalse);
      expect(report.simultaneousMs, 0);
    });

    test('untimed operations are excluded from the chart entirely', () {
      final seg = _seg('A', 0, 5000);
      final report = buildTimeStudyReport(
        operations: [
          _op('A', OperationCategory.productive, 1),
          _op('B', OperationCategory.productive, 2), // never timed
        ],
        timing: {
          'A': OperationTiming(instance: _inst('A'), segments: [seg]),
        },
        subtypeById: const {},
        segments: [seg],
      );

      expect(report.timeline.map((r) => r.operation.id), ['A']);
      // ...but it still appears in the breakdown table.
      expect(report.rows.map((r) => r.operation.id), ['A', 'B']);
    });
  });
}
