import 'package:flutter/material.dart';

/// A labelled figure in a summary strip, used by the Time Study report and the
/// study workspace header so the two read as one app.
///
/// Wrap these in a [Wrap] rather than a [Row]: the workspace header carries
/// three of them beside the study metadata, which does not fit a narrow window.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.footnote,
    this.valueColor,
  });

  final String label;
  final String value;

  /// Small caption under the value — used to disclose that a figure is
  /// computed over only part of the study.
  final String? footnote;

  /// Overrides the value colour; null keeps the default text colour.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
          if (footnote != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(footnote!,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }
}
