import '../../../data/database/database.dart';
import 'sampling_report.dart';

/// Cross-study comparison (DESIGN.md §4, §11.9).
///
/// Operations are matched **by catalog id**, which §11.8 made a durable
/// snapshot value precisely so this keeps working after someone tidies the
/// catalog. Scoped to one project for v1.
///
/// Both study types come in as a [SamplingReport], because a Time Study is a
/// study with one pass: its representative time is that pass's reading and its
/// n is 1, which the sampling builder already produces. One code path means the
/// two types cannot drift, and the n disclosure below falls out for free rather
/// than being a special case someone has to remember.

/// One study's figure for one operation.
class ComparisonCell {
  const ComparisonCell({
    required this.studyId,
    required this.meanMs,
    required this.occurrences,
    required this.readingCount,
    required this.efficiency,
  });

  final String studyId;

  /// The representative time: a Sampling Study's mean, a Time Study's single
  /// reading. Null when this study did not time the operation.
  ///
  /// **Summed over every occurrence** when a sequence contains the operation
  /// more than once — four inspections in a cycle make one figure, the
  /// inspection content of a pass. Averaging them instead would report "no
  /// change" when a process went from inspecting four times to twice, which is
  /// precisely the improvement a comparison exists to show.
  final double? meanMs;

  /// How many times the operation appears in this study's sequence.
  ///
  /// Disclosed alongside the time, because a figure summed over four
  /// occurrences and one measured once are otherwise the same number.
  final int occurrences;

  /// How many readings stand behind [meanMs]. **Always shown** — a mean over
  /// six passes and one press of a stopwatch are otherwise the same number in
  /// the same column (§11.9).
  ///
  /// The **weakest** occurrence governs: a sum is only as trustworthy as the
  /// least-measured thing in it.
  final int readingCount;

  /// Σ reference ÷ Σ representative time over the occurrences, per §3.6 — not
  /// one occurrence's standard against the summed time, which would report a
  /// process that inspects four times as four times over its standard.
  final double? efficiency;

  bool get hasValue => meanMs != null;

  /// True when a single reading is being presented beside means. Drawn
  /// differently on the trend so a lone stopwatch press cannot read as a
  /// settled figure.
  bool get isSingleReading => hasValue && readingCount == 1;
}

/// One operation, across every study that timed it.
class ComparisonRow {
  const ComparisonRow({
    required this.catalogOperationId,
    required this.name,
    required this.referenceStandardMs,
    required this.cells,
  });

  final String catalogOperationId;

  /// The name from the **most recent** study that carries this operation.
  ///
  /// Names are snapshotted per study (§3.3) and can legitimately differ between
  /// them; showing the newest is the least surprising choice, and the catalog
  /// itself cannot be consulted because §11.8 deliberately dropped that link.
  final String name;

  /// Likewise from the most recent study. A standard revised between studies
  /// is a real event, and comparing against the current one is what an analyst
  /// means by "are we meeting it".
  final int? referenceStandardMs;

  /// One per study, in the same order as [CrossStudyComparison.studies].
  final List<ComparisonCell> cells;

  Iterable<ComparisonCell> get measured => cells.where((c) => c.hasValue);

  int get studiesWithValue => measured.length;

  /// True when only one study timed it — there is a row but nothing to compare.
  bool get isSingleStudy => studiesWithValue < 2;

  /// Change from the first study that timed it to the last, as a fraction of
  /// the first. Negative means it got faster. Null when fewer than two studies.
  double? get trend {
    final values = measured.toList();
    if (values.length < 2) return null;
    final first = values.first.meanMs!;
    final last = values.last.meanMs!;
    if (first == 0) return null;
    return (last - first) / first;
  }
}

/// An operation that could not take part, and why.
class UnmatchedOperation {
  const UnmatchedOperation({required this.name, required this.studyName});

  final String name;
  final String studyName;
}

/// The assembled comparison.
class CrossStudyComparison {
  const CrossStudyComparison({
    required this.studies,
    required this.rows,
    required this.unmatched,
  });

  /// In date order, oldest first — the columns of the table and the x axis of
  /// the trend.
  final List<Study> studies;

  final List<ComparisonRow> rows;

  /// Operations left out for having no catalog link — custom or unplanned ones.
  ///
  /// **Named, not silently dropped** (§11.9). This is the artifact most likely
  /// to be read by someone who ran neither study, and a comparison that quietly
  /// omits a third of the work content is worse than one that admits it.
  final List<UnmatchedOperation> unmatched;

  bool get isEmpty => rows.isEmpty;

  /// True when any figure in the table rests on a single reading, so the view
  /// can explain its own notation rather than leaving a symbol unaccounted for.
  bool get hasSingleReadings =>
      rows.any((r) => r.cells.any((c) => c.isSingleReading));
}

/// One study's contribution.
class ComparisonInput {
  const ComparisonInput({
    required this.study,
    required this.operations,
    required this.report,
  });

  final Study study;
  final List<StudyOperation> operations;

  /// Built by `buildSamplingReport`, whatever the study's type.
  final SamplingReport report;
}

CrossStudyComparison buildCrossStudyComparison(List<ComparisonInput> inputs) {
  // Oldest first: a trend read right-to-left is a trend read backwards.
  final ordered = [...inputs]
    ..sort((a, b) => a.study.performedAt.compareTo(b.study.performedAt));

  final unmatched = <UnmatchedOperation>[];
  // Insertion-ordered, so rows come out in the sequence order of the study that
  // first introduced each operation rather than in hash order.
  final byCatalogId = <String, List<({ComparisonInput input, SamplingReportRow row})>>{};

  for (final input in ordered) {
    final rowsByOperationId = {
      for (final row in input.report.rows) row.operation.id: row,
    };
    final sequence = [...input.operations]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    for (final operation in sequence) {
      final catalogId = operation.catalogOperationId;
      final row = rowsByOperationId[operation.id];
      if (catalogId == null) {
        // No catalog link means no key to match on — custom or unplanned. Only
        // worth naming if it was actually timed; an untimed one contributes
        // nothing to any comparison, matched or not.
        if (row != null && row.statistics != null) {
          unmatched.add(UnmatchedOperation(
            name: operation.name,
            studyName: input.study.name,
          ));
        }
        continue;
      }
      if (row == null) continue;
      (byCatalogId[catalogId] ??= []).add((input: input, row: row));
    }
  }

  final rows = <ComparisonRow>[];
  for (final entry in byCatalogId.entries) {
    final appearances = entry.value;
    // Skip an operation no study ever produced a figure for: a row of blanks
    // is not a comparison, it is noise.
    if (appearances.every((a) => a.row.statistics == null)) continue;

    // The most recent study decides the label and the standard.
    final newestStudyId = appearances.last.input.study.id;
    final newest = [
      for (final a in appearances)
        if (a.input.study.id == newestStudyId) a.row,
    ];
    // Summed over that study's occurrences, so the standard on the row is
    // comparable with the summed times in its cells rather than being one
    // occurrence's figure sitting beside a total.
    final references = [
      for (final row in newest)
        if (row.referenceStandardMs != null) row.referenceStandardMs!,
    ];

    rows.add(ComparisonRow(
      catalogOperationId: entry.key,
      name: newest.last.operation.name,
      referenceStandardMs:
          references.isEmpty ? null : references.reduce((a, b) => a + b),
      cells: [
        for (final input in ordered)
          _cellFor(
            input,
            // EVERY occurrence, not the first. A sequence that inspects four
            // times has four rows against this catalog id, and taking one would
            // drop three measured operations with nothing said — the silent
            // omission §11.9 exists to prevent.
            [
              for (final a in appearances)
                if (a.input.study.id == input.study.id) a.row,
            ],
          ),
      ],
    ));
  }

  return CrossStudyComparison(
    studies: [for (final input in ordered) input.study],
    rows: rows,
    unmatched: unmatched,
  );
}

ComparisonCell _cellFor(ComparisonInput input, List<SamplingReportRow> rows) {
  final measured = [
    for (final row in rows)
      if (row.statistics != null) row,
  ];
  if (measured.isEmpty) {
    return ComparisonCell(
      studyId: input.study.id,
      meanMs: null,
      occurrences: 0,
      readingCount: 0,
      efficiency: null,
    );
  }

  var total = 0.0;
  var referenceTotal = 0;
  var hasReference = false;
  var weakest = measured.first.includedCount;
  for (final row in measured) {
    total += row.statistics!.mean;
    final reference = row.referenceStandardMs;
    if (reference != null) {
      referenceTotal += reference;
      hasReference = true;
    }
    // The weakest occurrence governs: a sum is only as trustworthy as the
    // least-measured thing in it.
    weakest = row.includedCount < weakest ? row.includedCount : weakest;
  }

  return ComparisonCell(
    studyId: input.study.id,
    meanMs: total,
    occurrences: measured.length,
    readingCount: weakest,
    // Σ reference ÷ Σ observed (§3.6). One occurrence's standard against the
    // summed time would call a process that inspects four times four times
    // over its standard.
    efficiency: hasReference && total > 0 ? referenceTotal / total : null,
  );
}
