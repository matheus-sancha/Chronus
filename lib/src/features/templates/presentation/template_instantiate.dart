import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../projects/application/projects_providers.dart';
import '../../settings/application/settings_providers.dart';
import '../application/templates_providers.dart';

/// Prompts for a target project + study name, then instantiates [template]
/// into a new study (snapshotting its operations).
Future<void> instantiateTemplateFlow(
  BuildContext context,
  WidgetRef ref,
  Template template,
) async {
  final result = await showDialog<(String, String)>(
    context: context,
    builder: (context) => _InstantiateDialog(defaultName: template.name),
  );
  if (result == null) return;
  final analyst = ref.read(appSettingsProvider).value?.defaultAnalyst;
  await ref.read(templateRepositoryProvider).instantiate(
        templateId: template.id,
        projectId: result.$1,
        name: result.$2,
        analyst: analyst,
      );
  if (context.mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.templateStudyCreated)),
    );
  }
}

class _InstantiateDialog extends ConsumerStatefulWidget {
  const _InstantiateDialog({required this.defaultName});

  final String defaultName;

  @override
  ConsumerState<_InstantiateDialog> createState() => _InstantiateDialogState();
}

class _InstantiateDialogState extends ConsumerState<_InstantiateDialog> {
  late final _name = TextEditingController(text: widget.defaultName);
  String? _projectId;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsListProvider).value ?? const [];
    final selectedProject =
        (_projectId != null && projects.any((p) => p.id == _projectId))
            ? _projectId
            : (projects.isNotEmpty ? projects.first.id : null);
    final canCreate = selectedProject != null && _name.text.trim().isNotEmpty;

    return AlertDialog(
      title: Text(l10n.instantiateTitle),
      content: projects.isEmpty
          ? Text(l10n.instantiateNoProjects)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedProject,
                  decoration: InputDecoration(labelText: l10n.fieldProject),
                  items: [
                    for (final p in projects)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) => setState(() => _projectId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _name,
                  decoration:
                      InputDecoration(labelText: l10n.studyNameLabel),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: canCreate
              ? () => Navigator.of(context)
                  .pop((selectedProject, _name.text.trim()))
              : null,
          child: Text(l10n.createStudyAction),
        ),
      ],
    );
  }
}
