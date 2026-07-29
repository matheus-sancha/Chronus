import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/application/settings_providers.dart';
import '../../studies/application/studies_providers.dart';
import '../../studies/presentation/study_formatting.dart';
import '../application/projects_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final studiesAsync = ref.watch(studiesByProjectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(projectAsync.value?.name ?? l10n.navProjects),
        actions: [
          // Comparison is scoped to one project for v1 (§4), so the project is
          // where it belongs — and it only appears once there is more than one
          // study, since comparing a study with itself is not a thing.
          if ((studiesAsync.value?.length ?? 0) > 1)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              tooltip: l10n.compareAction,
              onPressed: () => context.push('/projects/$projectId/compare'),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.actionDelete,
            onPressed: () => _deleteProject(context, ref),
          ),
        ],
      ),
      body: studiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (studies) {
          if (studies.isEmpty) {
            return Center(child: Text(l10n.studiesEmpty));
          }
          final dateFmt = MaterialLocalizations.of(context);
          return ListView.builder(
            itemCount: studies.length,
            itemBuilder: (context, index) {
              final study = studies[index];
              return ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(study.name),
                subtitle: Text(
                  '${studyTypeLabel(l10n, study.type)} · '
                  '${dateFmt.formatShortDate(study.performedAt)}',
                ),
                onTap: () => context.push(
                  '/projects/$projectId/studies/${study.id}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createStudy(context, ref),
        tooltip: l10n.studyNewTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createStudy(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, StudyType)>(
      context: context,
      builder: (context) => const _NewStudyDialog(),
    );
    if (result == null || result.$1.isEmpty) return;
    final defaultAnalyst =
        ref.read(appSettingsProvider).value?.defaultAnalyst;
    final study = await ref.read(studyRepositoryProvider).create(
          projectId: projectId,
          name: result.$1,
          type: result.$2,
          analyst: defaultAnalyst,
        );
    // Flow straight into the details form to fill the rest of the header.
    if (context.mounted) {
      context.push('/projects/$projectId/studies/${study.id}/edit');
    }
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final project = ref.read(projectByIdProvider(projectId)).value;
    if (project == null) return;
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteProjectTitle,
      message: l10n.deleteProjectMessage(project.name),
    );
    if (!confirmed) return;
    await ref.read(projectRepositoryProvider).delete(projectId);
    if (context.mounted) context.pop();
  }
}

/// Collects a study name + type. Returns (name, type) or null if cancelled.
class _NewStudyDialog extends StatefulWidget {
  const _NewStudyDialog();

  @override
  State<_NewStudyDialog> createState() => _NewStudyDialogState();
}

class _NewStudyDialogState extends State<_NewStudyDialog> {
  final _nameController = TextEditingController();
  StudyType _type = StudyType.timeStudy;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.studyNewTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.studyNameLabel),
          ),
          const SizedBox(height: 16),
          SegmentedButton<StudyType>(
            segments: [
              ButtonSegment(
                value: StudyType.timeStudy,
                label: Text(l10n.studyTypeTime),
              ),
              ButtonSegment(
                value: StudyType.samplingStudy,
                label: Text(l10n.studyTypeSampling),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pop((_nameController.text.trim(), _type)),
          child: Text(l10n.actionCreate),
        ),
      ],
    );
  }
}
