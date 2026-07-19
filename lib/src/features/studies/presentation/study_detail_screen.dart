import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
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
        data: (study) {
          final dateFmt = MaterialLocalizations.of(context);
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(l10n.studyFieldType),
                subtitle: Text(studyTypeLabel(l10n, study.type)),
              ),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.studyFieldDate),
                subtitle: Text(dateFmt.formatFullDate(study.performedAt)),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.studyFieldAnalyst),
                subtitle: Text(
                  (study.analyst != null && study.analyst!.isNotEmpty)
                      ? study.analyst!
                      : l10n.settingsAnalystEmpty,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  l10n.studyOperationsSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  l10n.studyOperationsPending,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          );
        },
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
