import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/sampling_report.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// The aggregate Sampling Study report. Every §11 decision that produces a
/// number is pinned here, because these are the figures a report hands to
/// someone who did not run the study.
void main() {
  StudyOperation op(
    String id,
    double order, {
    int? reference,
    bool unplanned = false,
    OperationCategory category = OperationCategory.productive,
    String? subtypeId,
  }) =>
      StudyOperation(
        id: id,
        studyId: 'study-1',
        orderIndex: order,
        name: 'Op $id',
        category: category,
        subtypeId: subtypeId,
        referenceStandardMs: reference,
        isUnplanned: unplanned,
        createdAt: DateTime(2026, 7, 27),
      );

  Observation observation(int index, {DateTime? excludedAt, String? reason}) =>
      Observation(
        id: 'obs-$index',
        studyId: 'study-1',
        sequenceIndex: index,
        performedAt: DateTime(2026, 7, 27),
        excludedAt: excludedAt,
        exclusionReason: reason,
        createdAt: DateTime(2026, 7, 27),
      );

  /// An operation's timing in one pass, expressed as a finished measurement.
  OperationTiming timed(
    int ms, {
    bool manual = false,
    DateTime? excludedAt,
    String? reason,
  }) =>
      OperationTiming(
        instance: OperationInstance(
          id: 'i',
          observationId: 'o',
          studyOperationId: 's',
          manualActualMs: manual ? ms : null,
          completedAt: DateTime(2026, 7, 27),
          excludedAt: excludedAt,
          exclusionReason: reason,
          createdAt: DateTime(2026, 7, 27),
        ),
        segments: manual
            ? const []
            : [
                OperationTimeSegment(
                  id: 'g',
                  operationInstanceId: 'i',
                  startAtMs: 0,
                  endAtMs: ms,
                  createdAt: DateTime(2026, 7, 27),
                ),
              ],
      );

  /// Builds a report over one operation measured once per pass.
  SamplingReport reportOf(
    List<OperationTiming?> perPass, {
    int? reference,
    double precision = 0.05,
    List<Observation>? observations,
  }) {
    final passes = [
      for (var i = 0; i < perPass.length; i++)
        PassTiming(
          observation: observations?[i] ?? observation(i),
          timingByOperation: perPass[i] == null ? {} : {'a': perPass[i]!},
        ),
    ];
    return buildSamplingReport(
      operations: [op('a', 1, reference: reference)],
      passes: passes,
      subtypeById: const {},
      confidenceLevel: 0.95,
      relativePrecision: precision,
      nowMs: 0,
    );
  }

  group('readings matrix', () {
    test('is rectangular — a pass that never timed an operation is a hole', () {
      // §11.2: an operation added at pass 3 has fewer readings, and the hole has
      // to be visible as a hole rather than shift the other readings along.
      final report = reportOf([timed(1000), null, timed(1200)]);
      final row = report.rows.single;

      expect(row.readings, hasLength(3));
      expect(row.readings.map((r) => r.ms), [1000, null, 1200]);
      expect(row.readings.map((r) => r.passNumber), [1, 2, 3]);
      expect(row.includedCount, 2);
      expect(row.statistics!.count, 2);
    });

    test('an operation no pass ever timed is coverage, not a zero', () {
      final report = reportOf([null, null]);
      final row = report.rows.single;

      expect(row.isNeverTimed, isTrue);
      expect(row.statistics, isNull); // not zeroes
      expect(row.sampleSize, isNull);
      expect(report.adequacy.neverTimed.map((o) => o.id), ['a']);
      // It cannot make the study inadequate — it makes it incomplete.
      expect(row.countsTowardVerdict, isFalse);
    });
  });

  group('exclusion', () {
    test('an excluded reading leaves the statistics but keeps its place', () {
      // §11.3: non-destructive. The reading is still in the matrix, still
      // reported, and only out of the mean.
      final report = reportOf([
        timed(1000),
        timed(9000, excludedAt: DateTime(2026, 7, 27), reason: 'wire feed jam'),
        timed(1100),
        timed(1050),
      ]);
      final row = report.rows.single;

      expect(row.readings, hasLength(4)); // still four
      expect(row.readings[1].isExcluded, isTrue);
      expect(row.readings[1].excludedBy, ExcludedBy.reading);
      expect(row.readings[1].reason, 'wire feed jam');
      expect(row.readings[1].ms, 9000); // the value is not erased

      expect(row.includedCount, 3);
      expect(row.excludedCount, 1);
      expect(row.statistics!.count, 3);
      expect(row.statistics!.mean, closeTo(1050, 0.001)); // 9000 is not in it
      expect(report.excludedReadingCount, 1);
    });

    test('excluding a pass excludes its readings, and says which it was', () {
      final report = reportOf(
        [timed(1000), timed(5000), timed(1100)],
        observations: [
          observation(0),
          observation(1,
              excludedAt: DateTime(2026, 7, 27), reason: 'line starved'),
          observation(2),
        ],
      );
      final row = report.rows.single;

      expect(row.readings[1].isExcluded, isTrue);
      // Which grain excluded it, so putting the pass back visibly returns the
      // reading rather than leaving the analyst wondering.
      expect(row.readings[1].excludedBy, ExcludedBy.pass);
      expect(row.readings[1].reason, 'line starved');
      expect(row.statistics!.count, 2);
      expect(report.excludedPassCount, 1);
      expect(report.includedPassCount, 2);
    });

    test('an excluded pass does not count toward the passes taken', () {
      final report = reportOf(
        [timed(1000), timed(1000), timed(1000)],
        observations: [
          observation(0),
          observation(1, excludedAt: DateTime(2026, 7, 27)),
          observation(2),
        ],
      );
      expect(report.adequacy.passesTaken, 2);
    });
  });

  group('manual overrides', () {
    test('count toward the statistics and are marked', () {
      // §11.4: they ARE the reported time, so excluding them would give a
      // transcribed paper study no statistics at all. Marked, as §4 hatches
      // unmeasured Gantt blocks.
      final report = reportOf([
        timed(1000),
        timed(1200, manual: true),
        timed(1100),
      ]);
      final row = report.rows.single;

      expect(row.statistics!.count, 3); // all three
      expect(row.statistics!.mean, closeTo(1100, 0.001));
      expect(row.readings[1].isManual, isTrue);
      expect(row.readings[0].isManual, isFalse);
      expect(row.manualCount, 1);
      expect(report.manualReadingCount, 1);
    });

    test('a fully transcribed paper study still has statistics', () {
      final report = reportOf([
        timed(1000, manual: true),
        timed(1200, manual: true),
        timed(1100, manual: true),
      ]);
      expect(report.rows.single.statistics!.count, 3);
      expect(report.manualReadingCount, 3);
    });
  });

  group('adequacy', () {
    test('the worst included operation governs, and is named', () {
      // Steady op needs few passes; erratic op needs many. The study is judged
      // by the erratic one, because passes are taken through the sequence.
      final passes = [
        for (var i = 0; i < 5; i++)
          PassTiming(
            observation: observation(i),
            timingByOperation: {
              'steady': timed(1000 + i), // almost no spread
              'erratic': timed(1000 + i * 400), // wide
            },
          ),
      ];
      final report = buildSamplingReport(
        operations: [op('steady', 1), op('erratic', 2)],
        passes: passes,
        subtypeById: const {},
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nowMs: 0,
      );

      expect(report.adequacy.governing!.operation.id, 'erratic');
      expect(report.adequacy.state, AdequacyState.notAdequate);
      expect(report.adequacy.passesTaken, 5);
      expect(report.adequacy.passesRequired, greaterThan(5));
      expect(report.adequacy.shortfall,
          report.adequacy.passesRequired! - 5);
    });

    test('an unplanned operation is kept out of the verdict', () {
      // §11.2: an interruption timed once would otherwise pin the study at
      // "not adequate" forever, for a row that is not part of the sequence.
      final passes = [
        for (var i = 0; i < 5; i++)
          PassTiming(
            observation: observation(i),
            timingByOperation: {
              'planned': timed(1000 + i),
              // Timed in one pass only, and wildly different — exactly what
              // would govern if it counted.
              if (i == 2) 'interruption': timed(90000),
            },
          ),
      ];
      final report = buildSamplingReport(
        operations: [op('planned', 1), op('interruption', 1.5, unplanned: true)],
        passes: passes,
        subtypeById: const {},
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nowMs: 0,
      );

      expect(report.adequacy.governing!.operation.id, 'planned');
      expect(report.adequacy.state, AdequacyState.adequate);
      // Still reported, just not judged.
      final unplannedRow =
          report.rows.firstWhere((r) => r.operation.id == 'interruption');
      expect(unplannedRow.statistics!.count, 1);
      expect(unplannedRow.countsTowardVerdict, isFalse);
    });

    test('one reading makes the study not determinable, not inadequate', () {
      // There is no spread to extrapolate from, so there is no number the
      // study could be short OF — a different thing from being short (§11.5).
      final report = reportOf([timed(1000)]);
      expect(report.adequacy.state, AdequacyState.notDeterminable);
      expect(report.adequacy.passesRequired, isNull);
      expect(report.adequacy.shortfall, 0);
    });

    test('a perfectly repeatable operation is adequate at one pass', () {
      final report = reportOf([timed(1000), timed(1000), timed(1000)]);
      expect(report.adequacy.state, AdequacyState.adequate);
      expect(report.adequacy.passesRequired, 1);
    });

    test('tighter precision asks for more passes', () {
      final readings = [timed(1000), timed(1100), timed(1050), timed(1080)];
      final loose = reportOf(readings, precision: 0.10);
      final tight = reportOf(readings, precision: 0.01);
      expect(tight.adequacy.passesRequired!,
          greaterThan(loose.adequacy.passesRequired!));
    });

    test('a study with nothing timed says so rather than dividing by zero', () {
      final report = reportOf([null, null]);
      expect(report.adequacy.state, AdequacyState.nothingTimed);
      expect(report.adequacy.governing, isNull);
    });
  });

  group('roll-ups run on means', () {
    test('work content is a representative pass, not a total across passes', () {
      // Three passes of ~1000 ms is 1000 ms of work content, not 3000.
      final report = reportOf([timed(1000), timed(1100), timed(900)]);
      expect(report.meanWorkContentMs, closeTo(1000, 0.001));
      expect(
        report.workContentByCategory[OperationCategory.productive],
        closeTo(1000, 0.001),
      );
    });

    test('efficiency compares the reference against the mean', () {
      final report = reportOf([timed(1000), timed(1200)], reference: 1100);
      // mean 1100, reference 1100 → exactly met.
      expect(report.efficiency, closeTo(1.0, 0.001));
      expect(report.rows.single.efficiency, closeTo(1.0, 0.001));
    });

    test('waste is ranked by mean time, heaviest first', () {
      final subtypes = {
        'waiting': OperationSubtype(
          id: 'waiting',
          category: OperationCategory.unproductive,
          name: 'Waiting',
          isBuiltIn: true,
          createdAt: DateTime(2026, 7, 27),
        ),
        'motion': OperationSubtype(
          id: 'motion',
          category: OperationCategory.unproductive,
          name: 'Motion',
          isBuiltIn: true,
          createdAt: DateTime(2026, 7, 27),
        ),
      };
      final passes = [
        for (var i = 0; i < 2; i++)
          PassTiming(
            observation: observation(i),
            timingByOperation: {'w': timed(400), 'm': timed(900)},
          ),
      ];
      final report = buildSamplingReport(
        operations: [
          op('w', 1,
              category: OperationCategory.unproductive, subtypeId: 'waiting'),
          op('m', 2,
              category: OperationCategory.unproductive, subtypeId: 'motion'),
        ],
        passes: passes,
        subtypeById: subtypes,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nowMs: 0,
      );

      expect(report.wastePareto.map((b) => b.subtype?.name), ['Motion', 'Waiting']);
      expect(report.wastePareto.first.ms, closeTo(900, 0.001));
    });
  });

  test('rows come out in planned-sequence order, whatever order they went in',
      () {
    final report = buildSamplingReport(
      operations: [op('c', 3), op('a', 1), op('b', 2)],
      passes: [
        PassTiming(
          observation: observation(0),
          timingByOperation: {'a': timed(100), 'b': timed(200), 'c': timed(300)},
        ),
      ],
      subtypeById: const {},
      confidenceLevel: 0.95,
      relativePrecision: 0.05,
      nowMs: 0,
    );
    expect(report.rows.map((r) => r.operation.id), ['a', 'b', 'c']);
  });
}
