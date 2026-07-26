import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/duration_format.dart';
import '../../../common/stat_tile.dart';
import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../../export/presentation/export_button.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/media_gallery.dart';
import '../../studies/application/studies_providers.dart';
import '../../studies/application/timing_model.dart';
import '../../studies/application/timing_providers.dart';
import '../application/time_study_report.dart';
import 'timeline_gantt.dart';

/// Time Study report: observed vs reference, efficiency, and the sequence
/// timeline. Read-only — timing is captured in the workspace. Percentages use
/// work content; elapsed and simultaneous totals are surfaced separately
/// (DESIGN.md §3.5, §4).
class TimeStudyReportScreen extends ConsumerWidget {
  const TimeStudyReportScreen({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final operations = ref.watch(studyOperationsProvider(studyId)).value ??
        const <StudyOperation>[];
    final observation = ref.watch(observationProvider(studyId)).value;
    final instances = observation == null
        ? const <OperationInstance>[]
        : (ref.watch(operationInstancesProvider(observation.id)).value ??
            const <OperationInstance>[]);
    final segments = observation == null
        ? const <OperationTimeSegment>[]
        : (ref.watch(operationSegmentsProvider(observation.id)).value ??
            const <OperationTimeSegment>[]);
    final study = ref.watch(studyByIdProvider(studyId)).value;
    final subtypes = ref.watch(subtypesProvider).value ?? const [];
    final mediaCounts =
        ref.watch(operationMediaCountsProvider).value ?? const <String, int>{};

    final timing = timingByOperation(instances: instances, segments: segments);
    final report = buildTimeStudyReport(
      operations: operations,
      timing: timing,
      subtypeById: {for (final s in subtypes) s.id: s},
      segments: segments,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportTitle),
        actions: [
          // Same gate as the body: nothing timed, nothing worth exporting.
          if (study != null && report.totalWorkContentMs > 0)
            ExportButton(
              study: study,
              report: report,
              timing: timing,
            ),
        ],
      ),
      body: report.totalWorkContentMs == 0
          ? Center(child: Text(l10n.reportEmpty))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summary(context, l10n, report),
                const SizedBox(height: 24),
                _sectionTitle(context, l10n.reportRollupTitle),
                _RollupBar(report: report),
                if (report.timeline.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(context, l10n.reportTimelineTitle),
                  TimelineGantt(report: report),
                ],
                if (report.wastePareto.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(context, l10n.reportParetoTitle),
                  _ParetoChart(report: report),
                ],
                const SizedBox(height: 24),
                _sectionTitle(context, l10n.studyOperationsSection),
                _breakdown(context, ref, l10n, report, timing, mediaCounts),
              ],
            ),
    );
  }

  Widget _summary(
      BuildContext context, AppLocalizations l10n, TimeStudyReport r) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StatTile(
            label: l10n.reportTotalElapsed, value: formatHmsd(r.totalElapsedMs)),
        StatTile(
            label: l10n.reportWorkContent,
            value: formatHmsd(r.totalWorkContentMs)),
        // Real overlap (swept from the segments) — not work content, which
        // sums operations and double-counts it.
        StatTile(
            label: l10n.reportSimultaneous,
            value: formatHmsd(r.simultaneousMs)),
        StatTile(
            label: l10n.reportUnattributed,
            value: formatHmsd(r.unattributedMs)),
        StatTile(
            label: l10n.timingValueAddedRatio,
            value: '${(r.valueAddedRatio * 100).toStringAsFixed(1)}%'),
        StatTile(
            label: l10n.reportEfficiency,
            value: r.efficiency == null
                ? '—'
                : '${(r.efficiency! * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  // Column flex weights, shared by header and body so they stay aligned.
  static const _flexName = 3;
  static const _flexObserved = 2;
  static const _flexReference = 2;
  static const _flexEfficiency = 2;
  static const _flexNotes = 3;
  static const _flexImages = 2;

  Widget _breakdown(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TimeStudyReport r,
    Map<String, OperationTiming> timing,
    Map<String, int> mediaCounts,
  ) {
    final theme = Theme.of(context);
    String t(int? ms) => ms == null ? '—' : formatHmsd(ms);

    Widget headerCell(String label, int flex) => Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        );

    Widget cell(Widget child, int flex, Alignment align) => Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Align(alignment: align, child: child),
          ),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              headerCell(l10n.colOperation, _flexName),
              headerCell(l10n.colObserved, _flexObserved),
              headerCell(l10n.colReference, _flexReference),
              headerCell(l10n.reportEfficiency, _flexEfficiency),
              headerCell(l10n.colNotes, _flexNotes),
              headerCell(l10n.colImages, _flexImages),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final row in r.rows) ...[
          Row(
            children: [
              cell(
                Row(
                  children: [
                    Icon(Icons.circle,
                        size: 10, color: categoryColor(row.operation.category)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(row.operation.name,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                _flexName,
                Alignment.centerLeft,
              ),
              cell(Text(t(row.observedMs)), _flexObserved, Alignment.center),
              cell(Text(t(row.referenceStandardMs)), _flexReference,
                  Alignment.center),
              cell(_efficiency(theme, row.efficiency), _flexEfficiency,
                  Alignment.center),
              cell(
                Text(
                  (row.notes != null && row.notes!.isNotEmpty)
                      ? row.notes!
                      : '—',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                _flexNotes,
                Alignment.centerLeft,
              ),
              cell(
                _imagesButton(
                    context, ref, row, _photoCount(timing, mediaCounts, row)),
                _flexImages,
                Alignment.center,
              ),
            ],
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _imagesButton(BuildContext context, WidgetRef ref,
      OperationReportRow row, int count) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _openPhotos(context, ref, row.operation),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              count > 0 ? Icons.photo_library : Icons.add_photo_alternate_outlined,
              size: 18,
              color: count > 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text('$count', style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPhotos(
      BuildContext context, WidgetRef ref, StudyOperation op) async {
    final instanceId = await ref.read(timingRepositoryProvider).ensureInstanceId(
          studyId: studyId,
          studyOperationId: op.id,
        );
    if (!context.mounted) return;
    await showMediaGallery(
      context,
      ownerType: MediaOwnerType.operationInstance,
      ownerId: instanceId,
      title: op.name,
    );
  }

  int _photoCount(Map<String, OperationTiming> timing,
      Map<String, int> mediaCounts, OperationReportRow row) {
    final id = timing[row.operation.id]?.instance?.id;
    return id == null ? 0 : (mediaCounts[id] ?? 0);
  }

  Widget _efficiency(ThemeData theme, double? efficiency) {
    if (efficiency == null) return const Text('—');
    final pct = efficiency * 100;
    // ≥100% = met/beat the reference standard (favourable).
    final color = pct >= 100
        ? categoryColor(OperationCategory.productive)
        : categoryColor(OperationCategory.unproductive);
    return Text('${pct.toStringAsFixed(0)}%', style: TextStyle(color: color));
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

// --- widgets -----------------------------------------------------------------

/// 100% stacked bar of work content by category, with a labelled legend. Each
/// segment is directly labelled below, so category identity never rests on
/// colour alone (the amber/green/red are semantic status colours).
class _RollupBar extends StatelessWidget {
  const _RollupBar({required this.report});

  final TimeStudyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = report.totalWorkContentMs;
    final cats = [
      for (final c in OperationCategory.values)
        if ((report.workContentByCategory[c] ?? 0) > 0)
          (c, report.workContentByCategory[c]!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: cats[i].$2,
                    child: ColoredBox(color: categoryColor(cats[i].$1)),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final (c, ms) in cats)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: categoryColor(c)),
                const SizedBox(width: 8),
                Expanded(child: Text(categoryLabel(l10n, c))),
                Text(formatHmsd(ms)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(ms / total * 100).toStringAsFixed(1)}%',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


/// Ranked waste bars — a single-series magnitude chart, so one hue (the waste
/// status colour) for every bar; identity is carried by the text label.
class _ParetoChart extends StatelessWidget {
  const _ParetoChart({required this.report});

  final TimeStudyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = categoryColor(OperationCategory.unproductive);
    final max = report.wastePareto.first.ms;
    return Column(
      children: [
        for (final bar in report.wastePareto)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    bar.subtype != null
                        ? subtypeName(l10n, bar.subtype!)
                        : l10n.wasteUnlabeled,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: max == 0 ? 0 : bar.ms / max,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(formatHmsd(bar.ms), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}
