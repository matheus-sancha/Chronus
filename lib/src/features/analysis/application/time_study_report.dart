import 'dart:math' as math;

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

/// One drawn block of a timeline row, positioned by absolute epoch ms.
///
/// [measured] is false when the block is **not** backed by a timed segment —
/// a manual override that runs past what was actually measured, or an operation
/// with no segments at all. Those are drawn hatched, so an overlap involving
/// them reads as unverified rather than as observed concurrency.
class TimelineBlock {
  TimelineBlock({
    required this.startMs,
    required this.endMs,
    required this.measured,
  });

  final int startMs;
  final int endMs;
  final bool measured;

  int get durationMs => endMs - startMs;
}

/// One operation's row in the timeline. Blocks are in ascending time order; a
/// row has more than one when the operation was paused and resumed, and the
/// gaps between them are the pauses.
class TimelineRow {
  TimelineRow({required this.operation, required this.blocks});

  final StudyOperation operation;
  final List<TimelineBlock> blocks;

  int get startMs => blocks.first.startMs;
  int get endMs => blocks.last.endMs;
  bool get hasMeasured => blocks.any((b) => b.measured);
}

/// One ranked bar of the waste Pareto.
class WastePareto {
  WastePareto({required this.subtype, required this.ms});
  final OperationSubtype? subtype; // null = unproductive with no subtype
  final int ms;
}

/// The assembled Time Study report.
///
/// Four totals describe the run and they reconcile:
/// `totalElapsedMs = (covered by ≥1 operation) + unattributedMs`, while
/// [totalWorkContentMs] sums operations and so counts overlap twice — which is
/// exactly what [simultaneousMs] measures. Percentages/roll-ups use work
/// content.
class TimeStudyReport {
  TimeStudyReport({
    required this.rows,
    required this.totalElapsedMs,
    required this.totalWorkContentMs,
    required this.simultaneousMs,
    required this.unattributedMs,
    required this.valueAddedRatio,
    required this.efficiency,
    required this.workContentByCategory,
    required this.wastePareto,
    required this.timeline,
    required this.timelineStartMs,
    required this.timelineEndMs,
    required this.timelineHasClock,
  });

  final List<OperationReportRow> rows;

  /// Wall-clock span, first start → last end. Never the sum of operations.
  final int totalElapsedMs;

  /// Σ of operation times. Exceeds [totalElapsedMs] when work overlapped.
  final int totalWorkContentMs;

  /// Time during which two or more operations were running at once.
  ///
  /// Computed by sweeping the measured intervals — **not** by subtracting
  /// elapsed from work content, which is only equal when there are no gaps and
  /// goes negative when gaps exceed overlap.
  final int simultaneousMs;

  /// Time inside the span attributed to no operation at all (§3.5: dead time
  /// counts only when explicitly attributed). Large values mean the run has
  /// holes and the totals should be read with that in mind.
  final int unattributedMs;

  final double valueAddedRatio;

  /// Σ reference ÷ Σ observed over operations that have both. Null if none do.
  final double? efficiency;
  final Map<OperationCategory, int> workContentByCategory;
  final List<WastePareto> wastePareto;

  /// Gantt rows in planned-sequence order, so they line up with [rows].
  final List<TimelineRow> timeline;
  final int timelineStartMs;
  final int timelineEndMs;

  /// True when at least one operation was timed live, so the axis can be
  /// labelled with wall-clock times. False for a fully transcribed paper study,
  /// where the axis must stay relative rather than invent clock readings.
  final bool timelineHasClock;

  int get timelineSpanMs => timelineEndMs - timelineStartMs;
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

  final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
  final rows = <OperationReportRow>[];
  final workByCategory = <OperationCategory, int>{};
  final wasteBySubtype = <String?, int>{};
  var totalWork = 0;
  var refSum = 0;
  var obsSumWithRef = 0;

  for (final op in ordered) {
    final t = timing[op.id];
    final observed = t?.actualMs(now);
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
    }
  }

  final timeline = _buildTimeline(ordered, timing, now);
  final measured = [
    for (final row in timeline)
      for (final b in row.blocks)
        if (b.measured) (b.startMs, b.endMs),
  ];
  final sweep = _sweep(measured);
  final elapsed = totalWallClockMs(segments, now);

  final pareto = wasteBySubtype.entries
      .map((e) => WastePareto(subtype: subtypeById[e.key], ms: e.value))
      .toList()
    ..sort((a, b) => b.ms.compareTo(a.ms));

  final productive = workByCategory[OperationCategory.productive] ?? 0;

  return TimeStudyReport(
    rows: rows,
    totalElapsedMs: elapsed,
    totalWorkContentMs: totalWork,
    simultaneousMs: sweep.simultaneous,
    unattributedMs: math.max(0, elapsed - sweep.covered),
    valueAddedRatio: totalWork == 0 ? 0 : productive / totalWork,
    efficiency: obsSumWithRef == 0 ? null : refSum / obsSumWithRef,
    workContentByCategory: workByCategory,
    wastePareto: pareto,
    timeline: timeline,
    timelineStartMs: timeline.isEmpty
        ? 0
        : timeline.map((r) => r.startMs).reduce(math.min),
    timelineEndMs:
        timeline.isEmpty ? 0 : timeline.map((r) => r.endMs).reduce(math.max),
    timelineHasClock: measured.isNotEmpty,
  );
}

/// Lays out the Gantt rows.
///
/// Rows follow the **planned sequence** (not first-start) so they line up with
/// the breakdown table. Within a row, blocks sit at their true timestamps, and
/// total block width always equals the operation's reported time so the chart
/// and the table can never disagree:
///
/// * override longer than measured (the forgot-to-start case) → measured blocks
///   stay put and an unmeasured block extends past them;
/// * override shorter than measured → blocks are trimmed from the end;
/// * no segments at all → one unmeasured block, laid out after the clock ends
///   (or from zero, when nothing in the study was timed live).
List<TimelineRow> _buildTimeline(
  List<StudyOperation> ordered,
  Map<String, OperationTiming> timing,
  int now,
) {
  // Measured intervals per operation, with any still-running segment closed at
  // `now` so a report viewed mid-run still draws.
  final measuredByOp = <String, List<(int, int)>>{};
  for (final op in ordered) {
    final intervals = <(int, int)>[];
    for (final s in timing[op.id]?.segments ?? const <OperationTimeSegment>[]) {
      final end = s.endAtMs ?? now;
      if (end > s.startAtMs) intervals.add((s.startAtMs, end));
    }
    if (intervals.isNotEmpty) {
      intervals.sort((a, b) => a.$1.compareTo(b.$1));
      measuredByOp[op.id] = intervals;
    }
  }

  // Untimed operations are appended after the last real timestamp. With no
  // timestamps anywhere this stays 0, giving a relative (not clock) axis.
  var appendCursor = 0;
  for (final intervals in measuredByOp.values) {
    for (final (_, end) in intervals) {
      appendCursor = math.max(appendCursor, end);
    }
  }

  final rows = <TimelineRow>[];
  for (final op in ordered) {
    final reported = timing[op.id]?.actualMs(now);
    if (reported == null || reported <= 0) continue;

    final intervals = measuredByOp[op.id];
    final blocks = <TimelineBlock>[];

    if (intervals == null) {
      blocks.add(TimelineBlock(
        startMs: appendCursor,
        endMs: appendCursor + reported,
        measured: false,
      ));
      appendCursor += reported;
    } else {
      var remaining = reported;
      for (final (start, end) in intervals) {
        if (remaining <= 0) break;
        final take = math.min(remaining, end - start);
        blocks.add(TimelineBlock(
          startMs: start,
          endMs: start + take,
          measured: true,
        ));
        remaining -= take;
      }
      if (remaining > 0) {
        blocks.add(TimelineBlock(
          startMs: blocks.last.endMs,
          endMs: blocks.last.endMs + remaining,
          measured: false,
        ));
      }
    }
    rows.add(TimelineRow(operation: op, blocks: blocks));
  }
  return rows;
}

/// Sweeps half-open intervals, returning the time covered by **two or more** at
/// once (simultaneous) and by **at least one** (covered).
///
/// Simultaneity has to be swept rather than derived: `work − elapsed` equals it
/// only when the run has no gaps, and turns negative once gaps exceed overlap.
({int simultaneous, int covered}) _sweep(List<(int, int)> intervals) {
  if (intervals.isEmpty) return (simultaneous: 0, covered: 0);

  // +1 opens an interval, -1 closes it; at equal timestamps close before open
  // so two intervals merely touching are not counted as overlapping.
  final events = <(int, int)>[];
  for (final (start, end) in intervals) {
    events.add((start, 1));
    events.add((end, -1));
  }
  events.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));

  var depth = 0, previous = 0, simultaneous = 0, covered = 0;
  for (final (at, delta) in events) {
    final span = at - previous;
    if (depth >= 2) simultaneous += span;
    if (depth >= 1) covered += span;
    depth += delta;
    previous = at;
  }
  return (simultaneous: simultaneous, covered: covered);
}
