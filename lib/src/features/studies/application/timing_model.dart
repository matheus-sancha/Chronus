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
