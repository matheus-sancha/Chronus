import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../studies/application/timing_model.dart';
import 'sampling_statistics.dart';

/// The aggregate Sampling Study report (DESIGN.md §11.6).
///
/// Deliberately has **no elapsed, no simultaneous, no unattributed and no
/// Gantt**: those measure one run, and summing or averaging them across passes
/// produces figures that describe nothing — §4's `elapsed = covered +
/// unattributed` holds within a pass and nowhere else. A single pass IS a time
/// study, so it keeps its own `TimeStudyReport`, reached from the pass list.
///
/// Pure functions over rows, like `time_study_report.dart` and
/// `sampling_statistics.dart`: the numbers have to be identical on screen, in
/// the PDF and in the spreadsheet, which means exactly one place computes them.

/// The timing of one pass, as the report consumes it.
class PassTiming {
  const PassTiming({required this.observation, required this.timingByOperation});

  final Observation observation;
  final Map<String, OperationTiming> timingByOperation;

  bool get isExcluded => observation.excludedAt != null;
  int get number => observation.sequenceIndex + 1;
}

/// Why a reading is not in the statistics.
enum ExcludedBy {
  /// This single reading was excluded (§11.3).
  reading,

  /// The whole pass was, so every reading in it is out.
  pass,
}

/// One operation's time in one pass — the cell of the readings matrix.
class Reading {
  const Reading({
    required this.passNumber,
    required this.observationId,
    required this.ms,
    required this.isManual,
    required this.excludedBy,
    required this.reason,
  });

  final int passNumber;
  final String observationId;

  /// Null when the operation was not timed in this pass at all — a hole, which
  /// §11.2 allows: an operation added at pass 4 simply has fewer readings.
  final int? ms;

  /// Typed rather than measured. Counts toward the statistics and is marked,
  /// exactly as §4 hatches unmeasured Gantt blocks (§11.4).
  final bool isManual;

  final ExcludedBy? excludedBy;

  /// Why it was excluded, when someone said.
  final String? reason;

  bool get isExcluded => excludedBy != null;

  /// Present, and counting toward the mean.
  bool get isIncluded => ms != null && excludedBy == null;
}

/// One operation across every pass.
class SamplingReportRow {
  SamplingReportRow({
    required this.operation,
    required this.subtype,
    required this.readings,
    required this.statistics,
    required this.sampleSize,
  });

  final StudyOperation operation;
  final OperationSubtype? subtype;

  /// One per pass, in pass order — including the passes that did not time this
  /// operation, so the matrix is rectangular and a hole is visible as a hole.
  final List<Reading> readings;

  /// Over the **included** readings only. Null when none are.
  final OperationStatistics? statistics;

  /// Null when there are no statistics to judge.
  final SampleSizeVerdict? sampleSize;

  int? get referenceStandardMs => operation.referenceStandardMs;

  int get includedCount => readings.where((r) => r.isIncluded).length;
  int get excludedCount => readings.where((r) => r.isExcluded).length;
  int get manualCount =>
      readings.where((r) => r.isIncluded && r.isManual).length;

  /// True when no pass ever produced a time for this operation. Reported as
  /// coverage rather than as a failure — incomplete and inadequate are
  /// different problems (§11.5).
  bool get isNeverTimed => readings.every((r) => r.ms == null);

  /// Reference standard ÷ mean. Null when either is missing or zero.
  double? get efficiency {
    final mean = statistics?.mean;
    final reference = referenceStandardMs;
    if (mean == null || mean <= 0 || reference == null) return null;
    return reference / mean;
  }

  /// Kept out of the study-level verdict (§11.2): an interruption timed once
  /// would otherwise pin the study at "not adequate" forever, for a row that is
  /// not part of the standard sequence.
  bool get countsTowardVerdict => !operation.isUnplanned && !isNeverTimed;
}

/// The study-level answer to "is this study done?".
enum AdequacyState {
  /// Every included operation has the passes its variability calls for.
  adequate,

  /// At least one is short, and [SamplingAdequacy.governing] is the worst.
  notAdequate,

  /// An included operation has fewer than two readings, so there is no spread
  /// to extrapolate from and no number to be short of yet.
  notDeterminable,

  /// Nothing has been timed at all.
  nothingTimed,
}

/// Whether the study has enough passes, and which operation decides.
///
/// **The worst included operation governs** (§11.5). Passes are taken through
/// the whole sequence — you cannot add passes for one operation alone — so the
/// binding constraint is the maximum required across operations, and naming it
/// turns a grade into an instruction.
class SamplingAdequacy {
  const SamplingAdequacy({
    required this.state,
    required this.governing,
    required this.passesTaken,
    required this.passesRequired,
    required this.neverTimed,
  });

  final AdequacyState state;

  /// The operation whose requirement is the binding one, named so the analyst
  /// knows what to go and re-time.
  final SamplingReportRow? governing;

  /// Passes that count — excluded ones are not among them.
  final int passesTaken;

  /// What the governing operation asks for. Null unless [state] is
  /// [AdequacyState.adequate] or [AdequacyState.notAdequate].
  final int? passesRequired;

  /// Operations no pass ever timed. Coverage, not failure.
  final List<StudyOperation> neverTimed;

  bool get isAdequate => state == AdequacyState.adequate;

  int get shortfall {
    final required = passesRequired;
    if (required == null || required <= passesTaken) return 0;
    return required - passesTaken;
  }
}

/// The assembled Sampling Study report.
class SamplingReport {
  SamplingReport({
    required this.rows,
    required this.passes,
    required this.adequacy,
    required this.confidenceLevel,
    required this.relativePrecision,
    required this.meanWorkContentMs,
    required this.workContentByCategory,
    required this.wastePareto,
    required this.efficiency,
  });

  final List<SamplingReportRow> rows;

  /// Every pass, in order — the columns of the readings matrix. Excluded passes
  /// are here too: they are shown struck out rather than dropped, so the reader
  /// can see that a pass was taken and what happened to it.
  final List<PassTiming> passes;

  final SamplingAdequacy adequacy;
  final double confidenceLevel;
  final double relativePrecision;

  /// Σ of the per-operation means — the work content of a representative pass.
  /// Not an elapsed time, and deliberately not called one.
  final double meanWorkContentMs;

  final Map<OperationCategory, double> workContentByCategory;
  final List<SamplingWasteParetoBar> wastePareto;

  /// Σ reference ÷ Σ mean, over operations having both (§3.6).
  final double? efficiency;

  int get includedPassCount => passes.where((p) => !p.isExcluded).length;
  int get excludedPassCount => passes.where((p) => p.isExcluded).length;

  /// Total readings left out, at either grain — the report always states this
  /// beside the statistics rather than quietly shrinking n (§11.3).
  int get excludedReadingCount =>
      rows.fold(0, (sum, row) => sum + row.excludedCount);

  int get manualReadingCount =>
      rows.fold(0, (sum, row) => sum + row.manualCount);
}

/// One ranked bar of the waste Pareto, on mean times.
class SamplingWasteParetoBar {
  const SamplingWasteParetoBar({required this.subtype, required this.ms});
  final OperationSubtype? subtype; // null = unproductive with no subtype
  final double ms;
}

SamplingReport buildSamplingReport({
  required List<StudyOperation> operations,
  required List<PassTiming> passes,
  required Map<String, OperationSubtype> subtypeById,
  required double confidenceLevel,
  required double relativePrecision,
  int? nowMs,
}) {
  final ordered = [...operations]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final orderedPasses = [...passes]
    ..sort((a, b) => a.observation.sequenceIndex
        .compareTo(b.observation.sequenceIndex));
  final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;

  final rows = <SamplingReportRow>[];
  final workByCategory = <OperationCategory, double>{};
  final wasteBySubtype = <String?, double>{};
  var meanWorkContent = 0.0;
  var referenceSum = 0.0;
  var meanSumWithReference = 0.0;

  for (final op in ordered) {
    final readings = <Reading>[];
    for (final pass in orderedPasses) {
      final timing = pass.timingByOperation[op.id];
      final instance = timing?.instance;
      final ms = timing?.actualMs(now);
      readings.add(Reading(
        passNumber: pass.number,
        observationId: pass.observation.id,
        ms: ms,
        isManual: instance?.manualActualMs != null,
        // A reading in an excluded pass is out whether or not it was itself
        // flagged; reporting which of the two it was lets the analyst put the
        // pass back and see the reading return.
        excludedBy: ms == null
            ? null
            : instance?.excludedAt != null
                ? ExcludedBy.reading
                : pass.isExcluded
                    ? ExcludedBy.pass
                    : null,
        reason: instance?.excludedAt != null
            ? instance?.exclusionReason
            : pass.isExcluded
                ? pass.observation.exclusionReason
                : null,
      ));
    }

    final included = [
      for (final r in readings)
        if (r.isIncluded) r.ms!,
    ];
    final statistics = statisticsFor(included);
    final sampleSize = statistics == null
        ? null
        : requiredPasses(
            statistics: statistics,
            confidenceLevel: confidenceLevel,
            relativePrecision: relativePrecision,
          );

    final row = SamplingReportRow(
      operation: op,
      subtype: op.subtypeId != null ? subtypeById[op.subtypeId] : null,
      readings: readings,
      statistics: statistics,
      sampleSize: sampleSize,
    );
    rows.add(row);

    // Roll-ups run on the MEAN, so they describe a representative pass rather
    // than the total across however many passes happen to have been taken.
    final mean = statistics?.mean;
    if (mean != null) {
      meanWorkContent += mean;
      workByCategory[op.category] = (workByCategory[op.category] ?? 0) + mean;
      if (op.category == OperationCategory.unproductive) {
        wasteBySubtype[op.subtypeId] = (wasteBySubtype[op.subtypeId] ?? 0) + mean;
      }
      final reference = op.referenceStandardMs;
      if (reference != null) {
        referenceSum += reference;
        meanSumWithReference += mean;
      }
    }
  }

  final pareto = wasteBySubtype.entries
      .map((e) =>
          SamplingWasteParetoBar(subtype: subtypeById[e.key], ms: e.value))
      .toList()
    ..sort((a, b) => b.ms.compareTo(a.ms));

  return SamplingReport(
    rows: rows,
    passes: orderedPasses,
    adequacy: _adequacy(rows, orderedPasses),
    confidenceLevel: confidenceLevel,
    relativePrecision: relativePrecision,
    meanWorkContentMs: meanWorkContent,
    workContentByCategory: workByCategory,
    wastePareto: pareto,
    efficiency:
        meanSumWithReference > 0 ? referenceSum / meanSumWithReference : null,
  );
}

SamplingAdequacy _adequacy(
    List<SamplingReportRow> rows, List<PassTiming> passes) {
  final neverTimed = [
    for (final row in rows)
      if (row.isNeverTimed) row.operation,
  ];
  final judged = rows.where((r) => r.countsTowardVerdict).toList();
  final passesTaken = passes.where((p) => !p.isExcluded).length;

  if (judged.isEmpty) {
    return SamplingAdequacy(
      state: AdequacyState.nothingTimed,
      governing: null,
      passesTaken: passesTaken,
      passesRequired: null,
      neverTimed: neverTimed,
    );
  }

  // A single included operation with fewer than two readings makes the whole
  // study not-yet-determinable rather than inadequate: there is no spread to
  // extrapolate from, so there is no number it could be short of.
  final undecidable = judged.where((r) => r.sampleSize?.required_ == null);
  if (undecidable.isNotEmpty) {
    return SamplingAdequacy(
      state: AdequacyState.notDeterminable,
      governing: undecidable.first,
      passesTaken: passesTaken,
      passesRequired: null,
      neverTimed: neverTimed,
    );
  }

  // The worst one binds. `reduce` rather than a sort so the FIRST operation in
  // sequence order wins a tie — the earlier row is the one an analyst scanning
  // the table finds first, and either answer is equally correct.
  final governing = judged.reduce((a, b) =>
      b.sampleSize!.required_! > a.sampleSize!.required_! ? b : a);
  final required = governing.sampleSize!.required_!;

  return SamplingAdequacy(
    state: required <= passesTaken
        ? AdequacyState.adequate
        : AdequacyState.notAdequate,
    governing: governing,
    passesTaken: passesTaken,
    passesRequired: required,
    neverTimed: neverTimed,
  );
}
