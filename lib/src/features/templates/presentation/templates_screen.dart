import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../studies/presentation/study_formatting.dart';
import '../application/templates_providers.dart';
import 'template_instantiate.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final templates = ref.watch(templatesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTemplates)),
      body: templates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.templatesEmpty));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final template = items[index];
              return ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(template.name),
                subtitle: Text(studyTypeLabel(l10n, template.defaultStudyType)),
                onTap: () => context.push('/templates/${template.id}/sequence'),
                trailing: PopupMenuButton<_Action>(
                  onSelected: (action) => switch (action) {
                    _Action.createStudy =>
                      instantiateTemplateFlow(context, ref, template),
                    _Action.edit => _edit(context, ref, template),
                    _Action.delete => _delete(context, ref, template),
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _Action.createStudy,
                      child: Text(l10n.createStudyAction),
                    ),
                    PopupMenuItem(
                      value: _Action.edit,
                      child: Text(l10n.actionEdit),
                    ),
                    PopupMenuItem(
                      value: _Action.delete,
                      child: Text(l10n.actionDelete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        tooltip: l10n.templateNewTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<(String, StudyType)>(
      context: context,
      builder: (context) => TemplateDialog(title: l10n.templateNewTitle),
    );
    if (result == null || result.$1.isEmpty) return;
    final template = await ref.read(templateRepositoryProvider).create(
          name: result.$1,
          defaultStudyType: result.$2,
        );
    if (context.mounted) {
      context.push('/templates/${template.id}/sequence');
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Template template,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<(String, StudyType)>(
      context: context,
      builder: (context) => TemplateDialog(
        title: l10n.templateEditTitle,
        initialName: template.name,
        initialType: template.defaultStudyType,
      ),
    );
    if (result == null || result.$1.isEmpty) return;
    await ref.read(templateRepositoryProvider).update(
          id: template.id,
          name: result.$1,
          defaultStudyType: result.$2,
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Template template,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteTemplateTitle,
      message: l10n.deleteTemplateMessage(template.name),
    );
    if (!confirmed) return;
    await ref.read(templateRepositoryProvider).delete(template.id);
  }
}

enum _Action { createStudy, edit, delete }

/// Create/edit dialog for a template's settings.
/// Returns (name, defaultStudyType).
class TemplateDialog extends StatefulWidget {
  const TemplateDialog({
    super.key,
    required this.title,
    this.initialName = '',
    this.initialType = StudyType.timeStudy,
  });

  final String title;
  final String initialName;
  final StudyType initialType;

  @override
  State<TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<TemplateDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late StudyType _type = widget.initialType;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop((_name.text.trim(), _type));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.templateNameLabel),
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
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
