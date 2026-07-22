import '../../../common/duration_format.dart';
import 'time_study_report.dart';

/// One labelled tick on the timeline axis.
class TimelineTick {
  const TimelineTick({required this.ms, required this.label});

  /// Absolute position on the report's timeline, in the same epoch-ms space as
  /// [TimelineBlock.startMs].
  final int ms;
  final String label;
}

/// Evenly spaced axis ticks, shared by the on-screen Gantt and the PDF so the
/// two artifacts can never label the same chart differently.
///
/// Labels are wall-clock times when the study was actually timed live, and
/// elapsed-from-zero when it was not — a transcribed paper study must never
/// show clock readings no clock ever produced (DESIGN.md §3.5).
List<TimelineTick> timelineTicks(TimeStudyReport report, {int count = 5}) {
  assert(count >= 2);
  final span = report.timelineSpanMs;
  if (span <= 0) return const [];

  return [
    for (var i = 0; i < count; i++)
      () {
        final ms = report.timelineStartMs + (span * i ~/ (count - 1));
        return TimelineTick(
          ms: ms,
          label: report.timelineHasClock
              ? _clock(ms)
              : formatHmsd(ms - report.timelineStartMs),
        );
      }(),
  ];
}

/// `HH:MM:SS` in local time. Deliberately not locale-formatted: these are
/// stopwatch readings on a chart axis, where a fixed-width 24-hour reading
/// stays aligned and unambiguous.
String _clock(int epochMs) {
  final t = DateTime.fromMillisecondsSinceEpoch(epochMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}
