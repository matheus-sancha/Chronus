import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/cross_study_comparison.dart';
import 'package:chronus/src/features/analysis/application/sampling_report.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cross-study comparison (DESIGN.md §4, §11.9).
///
/// The comparison is the artifact most likely to be read by someone who ran
/// neither study, so what it discloses matters as much as what it computes.
void main() {
  StudyOperation op(
    String id,
    double order, {
    String? catalogId,
    String? name,
    int? reference,
    bool unplanned = false,
  }) =>
      StudyOperation(
        id: id,
        studyId: 'ignored',
        catalogOperationId: catalogId,
        orderIndex: order,
        name: name ?? 'Op $id',
        category: OperationCategory.productive,
        referenceStandardMs: reference,
        isUnplanned: unplanned,
        createdAt: DateTime(2026),
      );

  OperationTiming timed(int ms) => OperationTiming(
        instance: OperationInstance(
          id: 'i-$ms',
          observationId: 'o',
          studyOperationId: 's',
          completedAt: DateTime(2026),
          createdAt: DateTime(2026),
        ),
        segments: [
          OperationTimeSegment(
            id: 'g-$ms',
            operationInstanceId: 'i-$ms',
            startAtMs: 0,
            endAtMs: ms,
            createdAt: DateTime(2026),
          ),
        ],
      );

  Study study(String id, DateTime when, {StudyType? type}) => Study(
        id: id,
        projectId: 'p',
        type: type ?? StudyType.samplingStudy,
        name: 'Study $id',
        performedAt: when,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nextPassIndex: 1,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  /// One study, with a reading per pass for each operation given.
  ComparisonInput input(
    String id,
    DateTime when,
    List<StudyOperation> operations,
    List<Map<String, int>> passes, {
    StudyType? type,
  }) {
    final report = buildSamplingReport(
      operations: operations,
      passes: [
        for (var i = 0; i < passes.length; i++)
          PassTiming(
            observation: Observation(
              id: '$id-obs-$i',
              studyId: id,
              sequenceIndex: i,
              performedAt: when,
              createdAt: when,
            ),
            timingByOperation: {
              for (final e in passes[i].entries) e.key: timed(e.value),
            },
          ),
      ],
      subtypeById: const {},
      confidenceLevel: 0.95,
      relativePrecision: 0.05,
      nowMs: 0,
    );
    return ComparisonInput(
      study: study(id, when, type: type),
      operations: operations,
      report: report,
    );
  }

  test('studies come out oldest first, whatever order they went in', () {
    // A trend read right-to-left is a trend read backwards.
    final comparison = buildCrossStudyComparison([
      input('jul', DateTime(2026, 7, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1000}]),
      input('mar', DateTime(2026, 3, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1200}]),
      input('jun', DateTime(2026, 6, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1100}]),
    ]);

    expect(comparison.studies.map((s) => s.id), ['mar', 'jun', 'jul']);
    expect(comparison.rows.single.cells.map((c) => c.meanMs),
        [1200.0, 1100.0, 1000.0]);
  });

  test('operations match on catalog id, not on name', () {
    // The same catalog operation renamed between studies is still one row —
    // this is exactly what §11.8 protected by making the id a snapshot value.
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1),
          [op('x', 1, catalogId: 'c1', name: 'Weld seam')], [{'x': 1200}]),
      input('jul', DateTime(2026, 7, 1),
          [op('y', 1, catalogId: 'c1', name: 'Weld seam (revised)')],
          [{'y': 1000}]),
    ]);

    expect(comparison.rows, hasLength(1));
    // The newest study decides the label: names are snapshotted per study and
    // the catalog can no longer be consulted for a canonical one.
    expect(comparison.rows.single.name, 'Weld seam (revised)');
  });

  test('an operation with no catalog link is named, not silently dropped', () {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [
        op('a', 1, catalogId: 'c1'),
        op('b', 2, name: 'Rework'), // custom, no catalog link
        op('c', 3, name: 'Tool change', unplanned: true),
      ], [
        {'a': 1000, 'b': 500, 'c': 900},
      ]),
    ]);

    expect(comparison.rows, hasLength(1)); // only the matched one
    expect(comparison.unmatched.map((u) => u.name), ['Rework', 'Tool change']);
    expect(comparison.unmatched.first.studyName, 'Study mar');
  });

  test('an unmatched operation that was never timed is not worth naming', () {
    // It contributes nothing to any comparison, matched or not — listing it
    // would be noise in the one place that has to stay readable.
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [
        op('a', 1, catalogId: 'c1'),
        op('b', 2, name: 'Never timed'),
      ], [
        {'a': 1000},
      ]),
    ]);

    expect(comparison.unmatched, isEmpty);
  });

  test('reading counts travel with every figure', () {
    // §11.9: a mean over six passes and one press of a stopwatch are otherwise
    // the same number in the same column.
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1200}], type: StudyType.timeStudy),
      input('jul', DateTime(2026, 7, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1000}, {'a': 1100}, {'a': 1050}]),
    ]);

    final cells = comparison.rows.single.cells;
    expect(cells[0].readingCount, 1);
    expect(cells[0].isSingleReading, isTrue);
    expect(cells[1].readingCount, 3);
    expect(cells[1].isSingleReading, isFalse);
    expect(comparison.hasSingleReadings, isTrue);
    // A Time Study needs no special case: one pass, mean = that reading.
    expect(cells[0].meanMs, 1200);
    expect(cells[1].meanMs, closeTo(1050, 0.001));
  });

  test('a study that did not time an operation leaves a blank, not a zero', () {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [
        op('a', 1, catalogId: 'c1'),
        op('b', 2, catalogId: 'c2'),
      ], [
        {'a': 1000, 'b': 500},
      ]),
      // July's study never times c2.
      input('jul', DateTime(2026, 7, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 900}]),
    ]);

    final c2 = comparison.rows.firstWhere((r) => r.catalogOperationId == 'c2');
    expect(c2.cells[0].meanMs, 500);
    expect(c2.cells[1].meanMs, isNull); // blank, not 0
    expect(c2.cells[1].readingCount, 0);
    expect(c2.isSingleStudy, isTrue); // nothing to compare it against
  });

  test('efficiency uses the standard each study carried', () {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1),
          [op('a', 1, catalogId: 'c1', reference: 1000)], [{'a': 1250}]),
      input('jul', DateTime(2026, 7, 1),
          [op('a', 1, catalogId: 'c1', reference: 1000)], [{'a': 1000}]),
    ]);

    final cells = comparison.rows.single.cells;
    expect(cells[0].efficiency, closeTo(0.8, 0.001)); // 1000 / 1250
    expect(cells[1].efficiency, closeTo(1.0, 0.001));
    // The newest standard is the row's, because "are we meeting it" means the
    // one in force now.
    expect(comparison.rows.single.referenceStandardMs, 1000);
  });

  test('trend is first to last, and negative means faster', () {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1000}]),
      input('jun', DateTime(2026, 6, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 950}]),
      input('jul', DateTime(2026, 7, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 800}]),
    ]);

    // 1000 -> 800 is 20 % faster, measured across the gap the blanks would
    // otherwise hide.
    expect(comparison.rows.single.trend, closeTo(-0.2, 0.001));
  });

  test('trend needs two studies that actually timed it', () {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [op('a', 1, catalogId: 'c1')],
          [{'a': 1000}]),
      input('jul', DateTime(2026, 7, 1), [op('a', 1, catalogId: 'c1')], [{}]),
    ]);
    expect(comparison.rows.single.trend, isNull);
  });

  test('an excluded reading is already out before the comparison sees it', () {
    // The comparison consumes the sampling report, so §11.3's exclusion has
    // been applied by the time a representative time exists. Pinned because a
    // second averaging path here would be a place for the two to disagree.
    final operations = [op('a', 1, catalogId: 'c1')];
    final report = buildSamplingReport(
      operations: operations,
      passes: [
        PassTiming(
          observation: Observation(
            id: 'o1',
            studyId: 's',
            sequenceIndex: 0,
            performedAt: DateTime(2026, 3, 1),
            createdAt: DateTime(2026),
          ),
          timingByOperation: {'a': timed(1000)},
        ),
        PassTiming(
          observation: Observation(
            id: 'o2',
            studyId: 's',
            sequenceIndex: 1,
            performedAt: DateTime(2026, 3, 1),
            excludedAt: DateTime(2026, 3, 1),
            createdAt: DateTime(2026),
          ),
          timingByOperation: {'a': timed(9000)},
        ),
      ],
      subtypeById: const {},
      confidenceLevel: 0.95,
      relativePrecision: 0.05,
      nowMs: 0,
    );

    final comparison = buildCrossStudyComparison([
      ComparisonInput(
        study: study('s', DateTime(2026, 3, 1)),
        operations: operations,
        report: report,
      ),
    ]);

    final cell = comparison.rows.single.cells.single;
    expect(cell.meanMs, 1000); // not 5000
    expect(cell.readingCount, 1);
  });

  group('an operation that repeats in one sequence', () {
    // Real cronoanálise sequences repeat: a boring cycle inspects after every
    // pass of the tool. All of those rows carry the same catalog id.
    ComparisonInput cycle(
      String id,
      DateTime when,
      int inspections, {
      int each = 1000,
      int? reference,
    }) {
      final operations = [
        for (var i = 0; i < inspections; i++)
          op('insp$i', i + 1.0, catalogId: 'c-insp', name: 'Inspection',
              reference: reference),
      ];
      return input(id, when, operations, [
        {for (var i = 0; i < inspections; i++) 'insp$i': each},
      ]);
    }

    test('every occurrence counts, and the count is disclosed', () {
      // The bug this pins: taking the first occurrence dropped the other three
      // with nothing said — the silent omission §11.9 exists to prevent.
      final comparison = buildCrossStudyComparison([cycle('mar', DateTime(2026, 3, 1), 4)]);
      final cell = comparison.rows.single.cells.single;

      expect(cell.occurrences, 4);
      expect(cell.meanMs, 4000); // the inspection content of a pass, not 1000
    });

    test('summing is what makes a process improvement visible', () {
      // Four inspections down to two is the improvement a comparison exists to
      // show. Averaging the occurrences instead would report "no change".
      final comparison = buildCrossStudyComparison([
        cycle('mar', DateTime(2026, 3, 1), 4),
        cycle('jul', DateTime(2026, 7, 1), 2),
      ]);
      final cells = comparison.rows.single.cells;

      expect(cells[0].meanMs, 4000);
      expect(cells[1].meanMs, 2000);
      expect(comparison.rows.single.trend, closeTo(-0.5, 0.001));
    });

    test('efficiency compares summed standard against summed time', () {
      // One occurrence's standard against the summed time would call a process
      // that inspects four times four times over its standard (§3.6).
      final comparison = buildCrossStudyComparison(
          [cycle('mar', DateTime(2026, 3, 1), 4, each: 1000, reference: 1000)]);
      final row = comparison.rows.single;

      expect(row.referenceStandardMs, 4000); // summed over the occurrences
      expect(row.cells.single.efficiency, closeTo(1.0, 0.001)); // met, not 25%
    });

    test('the weakest occurrence governs n', () {
      // A sum is only as trustworthy as the least-measured thing in it.
      final operations = [
        op('a', 1, catalogId: 'c1', name: 'Inspection'),
        op('b', 2, catalogId: 'c1', name: 'Inspection'),
      ];
      final comparison = buildCrossStudyComparison([
        input('mar', DateTime(2026, 3, 1), operations, [
          {'a': 1000, 'b': 1000},
          {'a': 1100}, // only the first was timed in pass 2
        ]),
      ]);

      final cell = comparison.rows.single.cells.single;
      expect(cell.occurrences, 2);
      expect(cell.readingCount, 1); // not 2
    });
  });

  test('a project with nothing comparable yields an empty comparison', () {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 1), [op('a', 1, name: 'Custom')],
          [{'a': 1000}]),
    ]);
    expect(comparison.isEmpty, isTrue);
    // ...and still says why, rather than showing a blank screen.
    expect(comparison.unmatched, hasLength(1));
  });
}
