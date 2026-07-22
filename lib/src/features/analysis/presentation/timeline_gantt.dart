import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/duration_format.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/time_study_report.dart';

/// The timeline as a Gantt on a real wall-clock axis: one row per operation in
/// planned-sequence order (so it lines up with the breakdown table below),
/// blocks at their true timestamps.
///
/// Concurrency shows as vertically aligned bars, unattributed dead time as
/// whitespace, and pauses as gaps within a row. Blocks not backed by a measured
/// segment are hatched, so an overlap involving one reads as unverified rather
/// than as observed simultaneity.
class TimelineGantt extends StatelessWidget {
  const TimelineGantt({super.key, required this.report});

  final TimeStudyReport report;

  /// Row labels need a fixed gutter so every bar shares one origin.
  static const _labelWidth = 132.0;

  /// Below this the chart scrolls horizontally rather than compressing into
  /// slivers. A real narrow layout lands with the rest of Phase 9.
  static const _minChartWidth = 620.0;

  static const _rowHeight = 22.0;
  static const _barHeight = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final span = report.timelineSpanMs;
    if (span <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(constraints.maxWidth, _minChartWidth);
        final barsWidth = chartWidth - _labelWidth;

        double x(int ms) =>
            (ms - report.timelineStartMs) / span * barsWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Axis(report: report, labelWidth: _labelWidth),
                const SizedBox(height: 4),
                for (final row in report.timeline)
                  SizedBox(
                    height: _rowHeight,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _labelWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              row.operation.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: barsWidth,
                          child: _GanttRow(
                            row: row,
                            x: x,
                            rowHeight: _rowHeight,
                            barHeight: _barHeight,
                            notMeasuredLabel: l10n.timelineNotMeasured,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!report.timelineHasClock)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.timelineRelativeAxis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tick labels: wall-clock times when the study was timed live, elapsed-from-
/// zero when it was not — a transcribed study must never show invented clock
/// readings.
class _Axis extends StatelessWidget {
  const _Axis({required this.report, required this.labelWidth});

  final TimeStudyReport report;
  final double labelWidth;

  static const _tickCount = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final span = report.timelineSpanMs;

    String label(int index) {
      final ms = report.timelineStartMs + (span * index ~/ (_tickCount - 1));
      if (!report.timelineHasClock) {
        return formatHmsd(ms - report.timelineStartMs);
      }
      final t = DateTime.fromMillisecondsSinceEpoch(ms);
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}:'
          '${t.second.toString().padLeft(2, '0')}';
    }

    return Row(
      children: [
        SizedBox(width: labelWidth),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < _tickCount; i++)
                Expanded(
                  child: Align(
                    // First tick hugs the origin, last hugs the end, so the
                    // labels bracket the bars instead of floating past them.
                    alignment: i == 0
                        ? Alignment.centerLeft
                        : i == _tickCount - 1
                            ? Alignment.centerRight
                            : Alignment.center,
                    child: Text(label(i),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One operation's bars, with a hairline connector spanning any pause so the
/// row still reads as a single operation.
class _GanttRow extends StatelessWidget {
  const _GanttRow({
    required this.row,
    required this.x,
    required this.rowHeight,
    required this.barHeight,
    required this.notMeasuredLabel,
  });

  final TimelineRow row;
  final double Function(int ms) x;
  final double rowHeight;
  final double barHeight;
  final String notMeasuredLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = categoryColor(row.operation.category);
    // Every child is positioned with explicit left/width/top/bottom. Sizing a
    // bar from its own constraints does not work here: a box with no child
    // collapses to zero width under the loose constraints a Stack hands out.
    final inset = (rowHeight - barHeight) / 2;

    return Stack(
      children: [
        if (row.blocks.length > 1)
          Positioned(
            left: x(row.startMs),
            width: math.max(x(row.endMs) - x(row.startMs), 1),
            top: rowHeight / 2,
            height: 1,
            child: ColoredBox(color: color.withValues(alpha: 0.45)),
          ),
        for (final block in row.blocks)
          Positioned(
            left: x(block.startMs),
            // Sub-pixel blocks would vanish entirely; keep them visible.
            width: math.max(x(block.endMs) - x(block.startMs), 2),
            top: inset,
            bottom: inset,
            child: Tooltip(
              message: block.measured
                  ? row.operation.name
                  : '${row.operation.name} — $notMeasuredLabel',
              child: block.measured
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )
                  : CustomPaint(
                      painter: _HatchPainter(
                        color: color,
                        background: theme.colorScheme.surface,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

/// Diagonal hatching for time that is reported but not measured. Deliberately a
/// line pattern rather than a lighter tint: a tint is indistinguishable from
/// solid once the report is printed in greyscale.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.color, required this.background});

  final Color color;
  final Color background;

  static const _spacing = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, Paint()..color = background);

    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = -size.height; i < size.width; i += _spacing) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), stroke);
    }
    canvas.restore();

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_HatchPainter old) =>
      old.color != color || old.background != background;
}
