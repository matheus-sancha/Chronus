import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../studies/application/timing_model.dart';

/// One row of the operation breakdown: observed time against its reference
/// standard, with efficiency = reference ÷ observed (>100% = beat the standard).
class OperationReportRow {
  OperationReportRow({
    required this.operation,
    required this.subtype,
    required this.observedMs,
    required this.efficiency,
    required this.notes,
  });

  final StudyOperation operation;
  final OperationSubtype? subtype;
  final int? observedMs;

  /// referenceStandard ÷ observed. Null when either is missing/zero.
  final double? efficiency;
  final String? notes;

  int? get referenceStandardMs => operation.referenceStandardMs;
}

/// A segment of the sequence timeline (ordered by when it was timed).
class TimelineSegment {
  TimelineSegment({required this.operation, required this.observedMs});
  final StudyOperation operation;
  final int observedMs;
}

/// One ranked bar of the waste Pareto.
class WastePareto {
  WastePareto({required this.subtype, required this.ms});
  final OperationSubtype? subtype; // null = unproductive with no subtype
  final int ms;
}

/// The assembled Time Study report. Percentages/roll-ups use **work content**
/// (the sum of operation times); [totalElapsedMs] is the wall-clock span, and
/// [totalWorkContentMs] the summed time including any concurrent overlap.
class TimeStudyReport {
  TimeStudyReport({
    required this.rows,
    required this.totalElapsedMs,
    required this.totalWorkContentMs,
    required this.valueAddedRatio,
    required this.efficiency,
    required this.workContentByCategory,
    required this.wastePareto,
    required this.timeline,
  });

  final List<OperationReportRow> rows;
  final int totalElapsedMs;
  final int totalWorkContentMs;
  final double valueAddedRatio;

  /// Σ reference ÷ Σ observed over operations that have both. Null if none do.
  final double? efficiency;
  final Map<OperationCategory, int> workContentByCategory;
  final List<WastePareto> wastePareto;
  final List<TimelineSegment> timeline;
}

TimeStudyReport buildTimeStudyReport({
  required List<StudyOperation> operations,
  required Map<String, OperationTiming> timing,
  required Map<String, OperationSubtype> subtypeById,
  required List<OperationTimeSegment> segments,
  int? nowMs,
}) {
  final ordered = [...operations]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  final rows = <OperationReportRow>[];
  final workByCategory = <OperationCategory, int>{};
  final wasteBySubtype = <String?, int>{};
  final timelineEntries = <({int? start, int order, TimelineSegment seg})>[];
  var totalWork = 0;
  var refSum = 0;
  var obsSumWithRef = 0;

  for (final op in ordered) {
    final t = timing[op.id];
    final observed = t?.actualMs(nowMs);
    final reference = op.referenceStandardMs;
    final efficiency = (observed != null && observed > 0 && reference != null)
        ? reference / observed
        : null;

    rows.add(OperationReportRow(
      operation: op,
      subtype: op.subtypeId != null ? subtypeById[op.subtypeId] : null,
      observedMs: observed,
      efficiency: efficiency,
      notes: t?.instance?.notes,
    ));

    if (observed != null) {
      workByCategory[op.category] = (workByCategory[op.category] ?? 0) + observed;
      totalWork += observed;
      if (op.category == OperationCategory.unproductive) {
        wasteBySubtype[op.subtypeId] =
            (wasteBySubtype[op.subtypeId] ?? 0) + observed;
      }
      if (reference != null) {
        refSum += reference;
        obsSumWithRef += observed;
      }
      if (observed > 0) {
        int? start;
        for (final s in (t?.segments ?? const [])) {
          start = start == null ? s.startAtMs : (s.startAtMs < start ? s.startAtMs : start);
        }
        timelineEntries.add((
          start: start,
          order: ordered.indexOf(op),
          seg: TimelineSegment(operation: op, observedMs: observed),
        ));
      }
    }
  }

  // Timeline: timed-live operations by first-start, manual-only ones after in
  // sequence order.
  timelineEntries.sort((a, b) {
    if (a.start != null && b.start != null) return a.start!.compareTo(b.start!);
    if (a.start != null) return -1;
    if (b.start != null) return 1;
    return a.order.compareTo(b.order);
  });

  final pareto = wasteBySubtype.entries
      .map((e) => WastePareto(subtype: subtypeById[e.key], ms: e.value))
      .toList()
    ..sort((a, b) => b.ms.compareTo(a.ms));

  final productive = workByCategory[OperationCategory.productive] ?? 0;

  return TimeStudyReport(
    rows: rows,
    totalElapsedMs: totalWallClockMs(segments, nowMs),
    totalWorkContentMs: totalWork,
    valueAddedRatio: totalWork == 0 ? 0 : productive / totalWork,
    efficiency: obsSumWithRef == 0 ? null : refSum / obsSumWithRef,
    workContentByCategory: workByCategory,
    wastePareto: pareto,
    timeline: [for (final e in timelineEntries) e.seg],
  );
}
