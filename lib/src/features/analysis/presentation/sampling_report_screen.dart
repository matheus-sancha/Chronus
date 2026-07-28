import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/duration_format.dart';
import '../../../common/stat_tile.dart';
import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../../studies/application/studies_providers.dart';
import '../../studies/application/timing_model.dart';
import '../../studies/application/timing_providers.dart';
import '../application/sampling_report.dart';

/// The aggregate Sampling Study report (DESIGN.md §11.6).
///
/// No Gantt, no elapsed, no simultaneous — those describe one run and mean
/// nothing summed across passes. A single pass keeps its own Time Study report,
/// opened from the pass list.
class SamplingReportScreen extends ConsumerWidget {
  const SamplingReportScreen({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final study = ref.watch(studyByIdProvider(studyId)).value;
    final operations = ref.watch(studyOperationsProvider(studyId)).value ??
        const <StudyOperation>[];
    final passes = ref.watch(passesProvider(studyId)).value ?? const [];
    final instances = ref.watch(studyInstancesProvider(studyId)).value ??
        const <OperationInstance>[];
    final segments = ref.watch(studySegmentsProvider(studyId)).value ??
        const <OperationTimeSegment>[];
    final subtypes = ref.watch(subtypesProvider).value ?? const [];

    if (study == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.samplingReportTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Instances and segments arrive as two flat lists for the whole study; the
    // per-pass timing each pass's column is built from is bucketed here, once.
    final segmentsByInstance = <String, List<OperationTimeSegment>>{};
    for (final segment in segments) {
      (segmentsByInstance[segment.operationInstanceId] ??= []).add(segment);
    }
    final instancesByPass = <String, List<OperationInstance>>{};
    for (final instance in instances) {
      (instancesByPass[instance.observationId] ??= []).add(instance);
    }

    final report = buildSamplingReport(
      operations: operations,
      passes: [
        for (final pass in passes)
          PassTiming(
            observation: pass.observation,
            timingByOperation: timingByOperation(
              instances: instancesByPass[pass.id] ?? const [],
              segments: [
                for (final instance in instancesByPass[pass.id] ?? const [])
                  ...?segmentsByInstance[instance.id],
              ],
            ),
          ),
      ],
      subtypeById: {for (final s in subtypes) s.id: s},
      confidenceLevel: study.confidenceLevel,
      relativePrecision: study.relativePrecision,
    );

    final hasAnything = report.rows.any((r) => r.statistics != null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.samplingReportTitle)),
      body: !hasAnything
          ? Center(child: Text(l10n.samplingReportEmpty))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Adequacy(report: report),
                const SizedBox(height: 24),
                _sectionTitle(context, l10n.samplingStatisticsTitle),
                _StatisticsTable(report: report),
                const SizedBox(height: 24),
                _sectionTitle(context, l10n.samplingReadingsTitle),
                _ReadingsMatrix(report: report),
                if (report.wastePareto.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(context, l10n.reportParetoTitle),
                  _WasteList(report: report),
                ],
              ],
            ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );

/// The headline: passes taken, whether that is enough, and what decides.
class _Adequacy extends StatelessWidget {
  const _Adequacy({required this.report});

  final SamplingReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final adequacy = report.adequacy;

    final (verdict, colour) = switch (adequacy.state) {
      AdequacyState.adequate => (
          l10n.samplingAdequate(adequacy.passesRequired!),
          theme.colorScheme.primary,
        ),
      AdequacyState.notAdequate => (
          l10n.samplingNotAdequate(adequacy.shortfall),
          theme.colorScheme.error,
        ),
      AdequacyState.notDeterminable => (
          l10n.samplingNotDeterminable,
          theme.colorScheme.outline,
        ),
      AdequacyState.nothingTimed => (
          l10n.samplingNothingTimed,
          theme.colorScheme.outline,
        ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.samplingCriteria(
                _trimZeroes(report.confidenceLevel * 100),
                _trimZeroes(report.relativePrecision * 100),
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.samplingPassesTaken(adequacy.passesTaken),
              style: theme.textTheme.titleLarge,
            ),
            Text(
              verdict,
              style: theme.textTheme.titleMedium?.copyWith(color: colour),
            ),
            // Naming the binding operation is what turns the verdict into an
            // instruction rather than a grade (§11.5).
            if (adequacy.governing != null) ...[
              const SizedBox(height: 8),
              Text(l10n.samplingGovernedBy(adequacy.governing!.operation.name)),
            ],
            // Coverage, reported separately: incomplete is not inadequate.
            if (adequacy.neverTimed.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.samplingNeverTimed(
                    adequacy.neverTimed.map((o) => o.name).join(', ')),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatTile(
                  label: l10n.samplingMeanWorkContent,
                  value: formatHmsd(report.meanWorkContentMs.round()),
                ),
                if (report.efficiency != null)
                  StatTile(
                    label: l10n.reportEfficiency,
                    value: '${(report.efficiency! * 100).round()}%',
                  ),
              ],
            ),
            // Disclosure, always — never a quietly shrunken n (§11.3, §11.4).
            if (report.excludedReadingCount > 0 ||
                report.manualReadingCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                [
                  if (report.excludedReadingCount > 0)
                    l10n.samplingExcludedNote(report.excludedReadingCount),
                  if (report.manualReadingCount > 0)
                    l10n.samplingManualNote(report.manualReadingCount),
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatisticsTable extends StatelessWidget {
  const _StatisticsTable({required this.report});

  final SamplingReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final governingId = report.adequacy.governing?.operation.id;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text(l10n.studyOperationsSection)),
          DataColumn(label: Text(l10n.samplingCount), numeric: true),
          DataColumn(label: Text(l10n.samplingMean), numeric: true),
          DataColumn(label: Text(l10n.samplingRange), numeric: true),
          DataColumn(label: Text(l10n.samplingStdDev), numeric: true),
          DataColumn(label: Text(l10n.samplingCv), numeric: true),
          DataColumn(label: Text(l10n.samplingRequired), numeric: true),
        ],
        rows: [
          for (final row in report.rows)
            DataRow(cells: [
              DataCell(Row(
                children: [
                  Text(row.operation.name),
                  if (row.operation.isUnplanned) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: l10n.samplingUnplannedNote,
                      child: Icon(Icons.info_outline,
                          size: 14, color: theme.colorScheme.outline),
                    ),
                  ],
                  if (row.operation.id == governingId) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_back,
                        size: 14, color: theme.colorScheme.error),
                  ],
                ],
              )),
              DataCell(Text(row.statistics == null
                  ? '—'
                  : '${row.statistics!.count}')),
              DataCell(Text(row.statistics == null
                  ? '—'
                  : formatHmsd(row.statistics!.mean.round()))),
              DataCell(Text(row.statistics == null
                  ? '—'
                  : formatHmsd(row.statistics!.range))),
              DataCell(Text(row.statistics?.standardDeviation == null
                  ? '—'
                  : formatHmsd(row.statistics!.standardDeviation!.round()))),
              DataCell(Text(row.statistics?.coefficientOfVariation == null
                  ? '—'
                  : '${(row.statistics!.coefficientOfVariation! * 100)
                      .toStringAsFixed(1)}%')),
              DataCell(Text(_requiredLabel(row))),
            ]),
        ],
      ),
    );
  }

  String _requiredLabel(SamplingReportRow row) {
    if (!row.countsTowardVerdict) return '—';
    final required = row.sampleSize?.required_;
    if (required == null) return '—';
    return '$required${row.includedCount >= required ? ' ✓' : ''}';
  }
}

/// Operations down, passes across — the shape of the paper form, and where a
/// reading is excluded from.
class _ReadingsMatrix extends ConsumerWidget {
  const _ReadingsMatrix({required this.report});

  final SamplingReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text(l10n.studyOperationsSection)),
          for (final pass in report.passes)
            DataColumn(
              numeric: true,
              label: Text(
                '${pass.number}',
                style: pass.isExcluded
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
            ),
        ],
        rows: [
          for (final row in report.rows)
            DataRow(cells: [
              DataCell(Text(row.operation.name)),
              for (final reading in row.readings)
                DataCell(
                  _ReadingCell(reading: reading),
                  onTap: reading.ms == null
                      ? null
                      : () => _toggle(context, ref, row, reading),
                ),
            ]),
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    SamplingReportRow row,
    Reading reading,
  ) async {
    final l10n = AppLocalizations.of(context);
    final timing = ref.read(timingRepositoryProvider);

    // A reading excluded because its whole pass was cannot be rescued on its
    // own — putting it back means putting the pass back, which is a pass-list
    // action. Saying so beats a control that appears to do nothing.
    if (reading.excludedBy == ExcludedBy.pass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.readingExcludedByPass)),
      );
      return;
    }

    if (reading.excludedBy == ExcludedBy.reading) {
      await timing.setReadingExcluded(
        observationId: reading.observationId,
        studyOperationId: row.operation.id,
        excluded: false,
      );
      return;
    }

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ExcludeReadingDialog(
        title: l10n.readingExcludeTitle(row.operation.name, reading.passNumber),
      ),
    );
    if (reason == null) return;
    await timing.setReadingExcluded(
      observationId: reading.observationId,
      studyOperationId: row.operation.id,
      excluded: true,
      reason: reason,
    );
  }
}

class _ReadingCell extends StatelessWidget {
  const _ReadingCell({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (reading.ms == null) return const Text('—');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatHmsd(reading.ms!),
          style: reading.isExcluded
              ? theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.outline,
                )
              : null,
        ),
        // Typed rather than measured — the same disclosure the Gantt makes by
        // hatching (§11.4).
        if (reading.isManual) ...[
          const SizedBox(width: 4),
          Icon(Icons.edit_outlined, size: 12, color: theme.colorScheme.outline),
        ],
      ],
    );
  }
}

class _ExcludeReadingDialog extends StatefulWidget {
  const _ExcludeReadingDialog({required this.title});

  final String title;

  @override
  State<_ExcludeReadingDialog> createState() => _ExcludeReadingDialogState();
}

class _ExcludeReadingDialogState extends State<_ExcludeReadingDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.readingExcludeMessage),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.passExcludeReasonHint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.readingExclude),
        ),
      ],
    );
  }
}

class _WasteList extends StatelessWidget {
  const _WasteList({required this.report});

  final SamplingReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final worst = report.wastePareto.first.ms;
    return Column(
      children: [
        for (final bar in report.wastePareto)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    bar.subtype == null
                        ? categoryLabel(l10n, OperationCategory.unproductive)
                        : subtypeName(l10n, bar.subtype!),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: worst == 0 ? 0 : bar.ms / worst,
                    minHeight: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(formatHmsd(bar.ms.round())),
              ],
            ),
          ),
      ],
    );
  }
}

String _trimZeroes(double value) {
  final rounded = value.toStringAsFixed(1);
  return rounded.endsWith('.0') ? rounded.substring(0, rounded.length - 2) : rounded;
}
