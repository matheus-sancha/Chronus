import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/duration_format.dart';
import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../export/presentation/comparison_export_button.dart';
import '../../projects/application/projects_providers.dart';
import '../application/comparison_providers.dart';
import '../application/cross_study_comparison.dart';

/// Cross-study comparison (DESIGN.md §4, §11.9), scoped to one project.
///
/// Two views of the same figures: a side-by-side table (operations × studies)
/// and a per-operation trend over time. What the screen discloses is as
/// load-bearing as what it computes — every representative time carries its n,
/// and the operations that could not be matched are named rather than dropped.
class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  /// Null until the analyst has chosen; then exactly what they picked.
  Set<String>? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final candidatesAsync =
        ref.watch(comparisonCandidatesProvider(widget.projectId));
    final candidatesValue = candidatesAsync.value ?? const <Study>[];
    // Resolved here rather than inside `when`, so the app bar's export action
    // sees the same selection the body does without either reaching into the
    // other. Everything is selected first time in: comparing is why the analyst
    // opened this, and an empty selection would make them tick boxes to see
    // anything at all.
    final selected = _selected ?? candidatesValue.map((s) => s.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.compareTitle),
        actions: [
          if (selected.length >= 2)
            _ExportAction(projectId: widget.projectId, studyIds: selected),
        ],
      ),
      body: candidatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (candidates) {
          if (candidates.isEmpty) {
            return Center(child: Text(l10n.compareNoStudies));
          }
          return Column(
            children: [
              _StudyPicker(
                candidates: candidates,
                selected: selected,
                onChanged: (ids) => setState(() => _selected = ids),
              ),
              const Divider(height: 1),
              Expanded(
                child: selected.length < 2
                    ? Center(child: Text(l10n.compareEmpty))
                    : _Comparison(studyIds: selected),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudyPicker extends StatelessWidget {
  const _StudyPicker({
    required this.candidates,
    required this.selected,
    required this.onChanged,
  });

  final List<Study> candidates;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(localeName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.compareSelected(selected.length),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final study in candidates)
                FilterChip(
                  label: Text(
                      '${study.name} · ${dateFormat.format(study.performedAt)}'),
                  selected: selected.contains(study.id),
                  onSelected: (on) {
                    final next = {...selected};
                    if (on) {
                      next.add(study.id);
                    } else {
                      next.remove(study.id);
                    }
                    onChanged(next);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Comparison extends ConsumerWidget {
  const _Comparison({required this.studyIds});

  final Set<String> studyIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async =
        ref.watch(crossStudyComparisonProvider(comparisonKey(studyIds)));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (comparison) {
        if (comparison.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.compareNothingMatched, textAlign: TextAlign.center),
                if (comparison.unmatched.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _UnmatchedNote(comparison: comparison),
                ],
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Table(comparison: comparison),
            const SizedBox(height: 12),
            if (comparison.hasSingleReadings)
              Text(l10n.compareSingleReadingNote,
                  style: Theme.of(context).textTheme.bodySmall),
            if (comparison.unmatched.isNotEmpty) ...[
              const SizedBox(height: 8),
              _UnmatchedNote(comparison: comparison),
            ],
            const SizedBox(height: 24),
            Text(l10n.compareTrendTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final row in comparison.rows)
              if (!row.isSingleStudy)
                _TrendRow(comparison: comparison, row: row),
          ],
        );
      },
    );
  }
}

/// The export action, which needs the loaded comparison the body is showing.
///
/// Its own widget so the app bar does not wait on the load: while the future is
/// in flight there is simply nothing to export, and the icon stays away rather
/// than offering an action that would fail.
class _ExportAction extends ConsumerWidget {
  const _ExportAction({required this.projectId, required this.studyIds});

  final String projectId;
  final Set<String> studyIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison =
        ref.watch(crossStudyComparisonProvider(comparisonKey(studyIds))).value;
    final project = ref.watch(projectByIdProvider(projectId)).value;
    if (comparison == null || project == null || comparison.isEmpty) {
      return const SizedBox.shrink();
    }
    return ComparisonExportButton(
      projectName: project.name,
      comparison: comparison,
    );
  }
}

/// Names what the comparison left out. §11.9: a comparison that quietly omits a
/// third of the work content is worse than one that admits it.
class _UnmatchedNote extends StatelessWidget {
  const _UnmatchedNote({required this.comparison});

  final CrossStudyComparison comparison;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = comparison.unmatched.map((u) => u.name).toSet().toList();
    return Text(
      l10n.compareUnmatchedNote(comparison.unmatched.length, names.join(', ')),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.comparison});

  final CrossStudyComparison comparison;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMM(localeName);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: [
          DataColumn(label: Text(l10n.studyOperationsSection)),
          for (final study in comparison.studies)
            DataColumn(
              numeric: true,
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(study.name, overflow: TextOverflow.ellipsis),
                  Text(dateFormat.format(study.performedAt),
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          DataColumn(label: Text(l10n.compareChange), numeric: true),
        ],
        rows: [
          for (final row in comparison.rows)
            DataRow(cells: [
              DataCell(Text(row.name)),
              for (final cell in row.cells) DataCell(_Cell(cell: cell)),
              DataCell(_Change(trend: row.trend)),
            ]),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.cell});

  final ComparisonCell cell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // A blank, never a zero: this study did not time the operation.
    if (!cell.hasValue) return const Text('—');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(formatHmsd(cell.meanMs!.round())),
        // n travels with every figure (§11.9). Without it, a mean over six
        // passes and one press of a stopwatch read identically.
        Text(
          l10n.compareReadings(cell.readingCount),
          style: theme.textTheme.bodySmall?.copyWith(
            color: cell.isSingleReading
                ? theme.colorScheme.error
                : theme.colorScheme.outline,
          ),
        ),
        // Likewise the occurrence count: a figure summed over four inspections
        // and one measured once are otherwise the same number.
        if (cell.occurrences > 1)
          Text(
            l10n.compareOccurrences(cell.occurrences),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
      ],
    );
  }
}

class _Change extends StatelessWidget {
  const _Change({required this.trend});

  final double? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (trend == null) return const Text('—');
    final percent = (trend! * 100);
    // Faster is an improvement, so a negative change is the good one — coloured
    // accordingly rather than by sign convention.
    final improved = percent < 0;
    return Text(
      '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: improved ? theme.colorScheme.primary : theme.colorScheme.error,
      ),
    );
  }
}

/// One operation's representative time over time.
///
/// A bar per study rather than a line chart: with three or four studies a line
/// implies a continuity that quarterly time studies do not have, and the bars
/// leave room to mark which figures rest on a single reading.
class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.comparison, required this.row});

  final CrossStudyComparison comparison;
  final ComparisonRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = row.measured.map((c) => c.meanMs!).toList();
    final worst = values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.name, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          for (var i = 0; i < row.cells.length; i++)
            if (row.cells[i].hasValue)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        comparison.studies[i].name,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: worst == 0 ? 0 : row.cells[i].meanMs! / worst,
                        minHeight: 12,
                        // Hollow-looking for a single reading, so the eye can
                        // tell evidence apart at a glance.
                        color: row.cells[i].isSingleReading
                            ? theme.colorScheme.outlineVariant
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 74,
                      child: Text(
                        '${formatHmsd(row.cells[i].meanMs!.round())}'
                        '${row.cells[i].isSingleReading ? ' ○' : ''}',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
