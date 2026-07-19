import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/projects_providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProjects)),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.projectsEmpty));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final project = items[index];
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(project.name),
                subtitle: project.notes == null ? null : Text(project.notes!),
                onTap: () => context.push('/projects/${project.id}'),
                trailing: PopupMenuButton<_ProjectAction>(
                  onSelected: (action) => switch (action) {
                    _ProjectAction.edit => _editProject(context, ref, project),
                    _ProjectAction.delete =>
                      _deleteProject(context, ref, project),
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ProjectAction.edit,
                      child: Text(l10n.actionEdit),
                    ),
                    PopupMenuItem(
                      value: _ProjectAction.delete,
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
        onPressed: () => _createProject(context, ref),
        tooltip: l10n.projectsNewTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => _ProjectDialog(title: l10n.projectsNewTitle),
    );
    if (result == null || result.$1.isEmpty) return;
    await ref
        .read(projectRepositoryProvider)
        .create(name: result.$1, notes: result.$2);
  }

  Future<void> _editProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => _ProjectDialog(
        title: l10n.projectEditTitle,
        initialName: project.name,
        initialNotes: project.notes,
      ),
    );
    if (result == null || result.$1.isEmpty) return;
    await ref.read(projectRepositoryProvider).update(
          id: project.id,
          name: result.$1,
          notes: result.$2,
        );
  }

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteProjectTitle,
      message: l10n.deleteProjectMessage(project.name),
    );
    if (!confirmed) return;
    await ref.read(projectRepositoryProvider).delete(project.id);
  }
}

enum _ProjectAction { edit, delete }

/// Create/edit dialog for a project. Returns (name, notes) or null if cancelled.
class _ProjectDialog extends StatefulWidget {
  const _ProjectDialog({
    required this.title,
    this.initialName = '',
    this.initialNotes,
  });

  final String title;
  final String initialName;
  final String? initialNotes;

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _notesController =
      TextEditingController(text: widget.initialNotes ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();
    Navigator.of(context).pop((name, notes.isEmpty ? null : notes));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.projectNameLabel),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: l10n.projectNotesLabel),
            maxLines: 2,
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
