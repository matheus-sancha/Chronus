import 'dart:math' as math;

import '../../../data/database/database.dart';

/// Lifecycle of one operation's timing, derived (never stored except the
/// `completedAt` marker that tells [paused] from [done]).
enum OperationTimingState { pending, running, paused, done }

/// A pure view over one operation's timing: its [OperationInstance] (if timing
/// has begun) and its [OperationTimeSegment]s. All time math lives here so the
/// UI and tests share one definition. Pass `nowMs` for deterministic tests;
/// omit it for live wall-clock.
class OperationTiming {
  OperationTiming({required this.instance, required this.segments});

  final OperationInstance? instance;
  final List<OperationTimeSegment> segments;

  bool get _hasOpenSegment => segments.any((s) => s.endAtMs == null);

  int? get manualActualMs => instance?.manualActualMs;

  /// Sum of segment durations (open segments count up to [nowMs]).
  int measuredMs([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    var sum = 0;
    for (final s in segments) {
      sum += (s.endAtMs ?? now) - s.startAtMs;
    }
    return sum;
  }

  /// The reported actual time: the manual override if set, else the measured
  /// sum. Null only when the operation is untimed (no override, no segments).
  int? actualMs([int? nowMs]) {
    if (manualActualMs != null) return manualActualMs;
    if (segments.isEmpty) return null;
    return measuredMs(nowMs);
  }

  bool get isTimed =>
      manualActualMs != null ||
      segments.isNotEmpty ||
      instance?.completedAt != null;

  OperationTimingState get state {
    if (_hasOpenSegment) return OperationTimingState.running;
    if (instance?.completedAt != null) return OperationTimingState.done;
    if (segments.isNotEmpty) return OperationTimingState.paused;
    if (manualActualMs != null) return OperationTimingState.done;
    return OperationTimingState.pending;
  }
}

/// Groups all timing rows of a run by operation. [instances] and [segments] are
/// the two flat streams from `TimingRepository`; this stitches them per
/// operation for the table.
Map<String, OperationTiming> timingByOperation({
  required List<OperationInstance> instances,
  required List<OperationTimeSegment> segments,
}) {
  final segmentsByInstance = <String, List<OperationTimeSegment>>{};
  for (final s in segments) {
    (segmentsByInstance[s.operationInstanceId] ??= []).add(s);
  }
  return {
    for (final i in instances)
      i.studyOperationId: OperationTiming(
        instance: i,
        segments: segmentsByInstance[i.id] ?? const [],
      ),
  };
}

/// What the lap key should do, given the state of a run (DESIGN.md §10.7).
///
/// A sealed result rather than a nullable operation id, because "do nothing"
/// comes in two kinds that have to be told apart: nothing *left* to start, and a
/// deliberate refusal to guess. They read differently to the analyst, and only
/// one of them means the run is finished.
sealed class LapAction {
  const LapAction();
}

/// Stop [studyOperationId] and start the next pending operation at the same
/// instant.
class LapAdvance extends LapAction {
  const LapAdvance(this.studyOperationId);

  final String studyOperationId;
}

/// Nothing was running; begin [studyOperationId].
class LapStart extends LapAction {
  const LapStart(this.studyOperationId);

  final String studyOperationId;
}

/// Two or more operations are running, so "the current one" has no meaning.
class LapAmbiguous extends LapAction {
  const LapAmbiguous();
}

/// Nothing is running and nothing is left untimed.
class LapNothing extends LapAction {
  const LapNothing();
}

/// Decides what one press of the lap key means.
///
/// Pure, so the rule can be tested without a widget or a database — and so the
/// rule has exactly one definition. The interesting case is [LapAmbiguous]:
/// under concurrency the key deliberately does nothing, because guessing which
/// of two running operations to stop risks stopping the wrong operator's timer,
/// which destroys evidence that cannot be recovered.
LapAction lapActionFor({
  required List<StudyOperation> ops,
  required Map<String, OperationTiming> timing,
}) {
  OperationTimingState stateOf(StudyOperation op) =>
      timing[op.id]?.state ?? OperationTimingState.pending;

  final running = [
    for (final op in ops)
      if (stateOf(op) == OperationTimingState.running) op,
  ];
  if (running.length > 1) return const LapAmbiguous();
  if (running.length == 1) return LapAdvance(running.single.id);

  for (final op in ops) {
    if (stateOf(op) == OperationTimingState.pending) return LapStart(op.id);
  }
  return const LapNothing();
}

/// Where an operation stands against its reference standard. Ordered by
/// severity — [_evaluateAlerts] and the latch both rely on `index` ranking.
enum OperationPace { onTrack, approaching, over }

/// Longest lead time the "approaching" alert will ever give.
const alertWindowCapMs = 30 * 1000;

/// Lead time before the reference standard at which "approaching" fires: a
/// tenth of the standard, capped at [alertWindowCapMs].
///
/// The 30 s is a **cap, not a floor**, and that is what keeps the rule free of
/// degenerate cases at both ends. As a floor, any operation shorter than the
/// constant would warn at or before its own start — and element-level
/// cronoanálise operations are routinely under 30 s. As a cap the window is
/// always a tenth of the operation, so it can never precede the start, while a
/// two-hour operation still gets a tight "ready to stop" cue instead of a
/// distant schedule warning.
int alertWindowMs(int referenceStandardMs) =>
    math.min(alertWindowCapMs, referenceStandardMs ~/ 10);

/// [elapsedMs] against [referenceStandardMs]. Null when the comparison does not
/// apply — no reference standard, or nothing timed yet — which callers render
/// as no colour and no sound rather than as "on track".
OperationPace? paceFor({
  required int? elapsedMs,
  required int? referenceStandardMs,
}) {
  if (elapsedMs == null ||
      referenceStandardMs == null ||
      referenceStandardMs <= 0) {
    return null;
  }
  if (elapsedMs >= referenceStandardMs) return OperationPace.over;
  if (elapsedMs >= referenceStandardMs - alertWindowMs(referenceStandardMs)) {
    return OperationPace.approaching;
  }
  return OperationPace.onTrack;
}

/// Σ of the operations' reported times — the study's work content, live.
///
/// Counts overlap twice by design, exactly like the report's
/// `totalWorkContentMs`. Compare it against [expectedTotal]; never against the
/// wall-clock span from [totalWallClockMs], which is not a sum.
int workContentMs(Iterable<OperationTiming> timings, [int? nowMs]) {
  var sum = 0;
  for (final t in timings) {
    sum += t.actualMs(nowMs) ?? 0;
  }
  return sum;
}

/// The study's planned time: Σ reference standard over **every** operation in
/// the sequence, with how many of them actually carry a standard.
///
/// Summing over all operations (rather than only those already timed) keeps
/// Expected a fixed target during a run instead of a figure that grows as you
/// work. The trade-off is that an operation without a standard silently
/// understates the plan, so [withReference] is reported alongside and the UI
/// shows the coverage whenever it is short of [total].
({int totalMs, int withReference, int total}) expectedTotal(
    List<StudyOperation> operations) {
  var totalMs = 0;
  var withReference = 0;
  for (final op in operations) {
    final reference = op.referenceStandardMs;
    if (reference == null) continue;
    totalMs += reference;
    withReference++;
  }
  return (
    totalMs: totalMs,
    withReference: withReference,
    total: operations.length,
  );
}

/// Total study time = the wall-clock span from the first segment start to the
/// last segment end (or now, for a still-open segment). Overlapping operations
/// are NOT summed — that would double-count simultaneous work. Zero when
/// nothing has been timed live.
int totalWallClockMs(List<OperationTimeSegment> segments, [int? nowMs]) {
  if (segments.isEmpty) return 0;
  final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
  var start = segments.first.startAtMs;
  var end = segments.first.endAtMs ?? now;
  for (final s in segments) {
    start = math.min(start, s.startAtMs);
    end = math.max(end, s.endAtMs ?? now);
  }
  return end - start;
}
