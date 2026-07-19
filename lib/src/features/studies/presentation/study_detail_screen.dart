import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../common/duration_format.dart';
import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/studies_providers.dart';
import 'study_formatting.dart';

class StudyDetailScreen extends ConsumerWidget {
  const StudyDetailScreen({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final studyAsync = ref.watch(studyByIdProvider(studyId));

    return Scaffold(
      appBar: AppBar(
        title: Text(studyAsync.value?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.actionEdit,
            onPressed: studyAsync.hasValue
                ? () => context.push(
                      '/projects/$projectId/studies/$studyId/edit',
                    )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.actionDelete,
            onPressed: studyAsync.hasValue
                ? () => _deleteStudy(context, ref, studyAsync.value!.name)
                : null,
          ),
        ],
      ),
      body: studyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (study) => _StudyBody(
          study: study,
          projectId: projectId,
          studyId: studyId,
        ),
      ),
    );
  }

  Future<void> _deleteStudy(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteStudyTitle,
      message: l10n.deleteStudyMessage(name),
    );
    if (!confirmed) return;
    await ref.read(studyRepositoryProvider).delete(studyId);
    if (context.mounted) context.pop();
  }
}

class _StudyBody extends ConsumerWidget {
  const _StudyBody({
    required this.study,
    required this.projectId,
    required this.studyId,
  });

  final Study study;
  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dateFmt = MaterialLocalizations.of(context);
    final operations = ref.watch(studyOperationsProvider(studyId));

    return ListView(
      children: [
        _row(context, Icons.category_outlined, l10n.studyFieldType,
            studyTypeLabel(l10n, study.type)),
        _row(context, Icons.event_outlined, l10n.studyFieldDate,
            dateFmt.formatFullDate(study.performedAt)),
        _row(context, Icons.person_outline, l10n.studyFieldAnalyst,
            study.analyst, emptyText: l10n.settingsAnalystEmpty),
        _row(context, Icons.percent_outlined, l10n.studyFieldAllowance,
            '${study.allowancePercent}%'),
        if (study.processType != null)
          _row(context, Icons.precision_manufacturing_outlined,
              l10n.studyFieldProcessType, study.processType),

        _section(context, l10n.studyDetailsSection),
        _optional(context, l10n.studyFieldPartProduct, study.partProduct),
        _optional(
            context, l10n.studyFieldProcessOperation, study.processOperation),
        _optional(context, l10n.studyFieldMachine, study.machineWorkstation),
        _optional(context, l10n.studyFieldLineCell, study.lineCell),
        _optional(context, l10n.studyFieldOperator, study.operatorName),
        _optional(context, l10n.studyFieldShift, study.shift),
        _optional(context, l10n.studyFieldWorkOrder, study.workOrderNumber),
        _optional(context, l10n.studyFieldNotes, study.notes),

        // Operations section with a manage action.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.studyOperationsSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.actionEdit,
                onPressed: () => context.push(
                  '/projects/$projectId/studies/$studyId/sequence',
                ),
              ),
            ],
          ),
        ),
        operations.when(
          loading: () => const SizedBox.shrink(),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$error'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  l10n.sequenceEmpty,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(items[i].name),
                    subtitle: Text(_operationSubtitle(l10n, items[i])),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _operationSubtitle(AppLocalizations l10n, StudyOperation op) {
    final parts = <String>[categoryLabel(l10n, op.category)];
    if (op.referenceStandardMs != null) {
      parts.add(formatHmsd(op.referenceStandardMs!));
    }
    return parts.join(' · ');
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String? value, {
    String? emptyText,
  }) {
    final display = (value != null && value.isNotEmpty) ? value : emptyText!;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(display),
    );
  }

  /// A ListTile only when the field is set (skipped otherwise).
  Widget _optional(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return ListTile(title: Text(label), subtitle: Text(value));
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
