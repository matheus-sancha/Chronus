import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/duration_input.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import 'classification_labels.dart';

/// Mutable holder for the common operation fields. The parent owns it (init,
/// read on save, dispose); [OperationFieldsForm] edits it in place.
class OperationDraft {
  OperationDraft({
    String name = '',
    this.category = OperationCategory.productive,
    this.subtypeId,
    this.referenceStandardMs,
  }) : nameController = TextEditingController(text: name);

  final TextEditingController nameController;
  OperationCategory category;
  String? subtypeId;
  int? referenceStandardMs;

  String get name => nameController.text.trim();

  void dispose() => nameController.dispose();
}

/// Shared editor for an operation's fields: name, type, subtype (scoped to the
/// type, with inline add), and reference-standard time. Used by the catalog
/// editor and the study/template custom-operation screens.
class OperationFieldsForm extends ConsumerStatefulWidget {
  const OperationFieldsForm({super.key, required this.draft});

  final OperationDraft draft;

  @override
  ConsumerState<OperationFieldsForm> createState() =>
      _OperationFieldsFormState();
}

class _OperationFieldsFormState extends ConsumerState<OperationFieldsForm> {
  OperationDraft get _draft => widget.draft;

  Future<void> _addSubtype() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _SubtypeDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    final created = await ref
        .read(catalogRepositoryProvider)
        .createSubtype(category: _draft.category, name: name.trim());
    if (mounted) setState(() => _draft.subtypeId = created.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allSubtypes = ref.watch(subtypesProvider).value ?? const [];
    final subtypesForCategory =
        allSubtypes.where((s) => s.category == _draft.category).toList();
    final currentSubtype =
        subtypesForCategory.any((s) => s.id == _draft.subtypeId)
            ? _draft.subtypeId
            : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _draft.nameController,
          decoration: InputDecoration(labelText: l10n.operationNameLabel),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<OperationCategory>(
          initialValue: _draft.category,
          decoration: InputDecoration(labelText: l10n.operationCategoryLabel),
          items: [
            for (final c in OperationCategory.values)
              DropdownMenuItem(value: c, child: Text(categoryLabel(l10n, c))),
          ],
          onChanged: (c) => setState(() {
            _draft.category = c ?? _draft.category;
            _draft.subtypeId = null;
          }),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: currentSubtype,
                decoration:
                    InputDecoration(labelText: l10n.operationSubtypeLabel),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.processTypeNone),
                  ),
                  for (final s in subtypesForCategory)
                    DropdownMenuItem(
                      value: s.id,
                      child: Text(subtypeName(l10n, s)),
                    ),
                ],
                onChanged: (v) => setState(() => _draft.subtypeId = v),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.subtypeNewTitle,
              onPressed: _addSubtype,
            ),
          ],
        ),
        const SizedBox(height: 16),
        DurationInput(
          label: l10n.operationReferenceStandardLabel,
          initialMs: _draft.referenceStandardMs,
          onChanged: (ms) => _draft.referenceStandardMs = ms,
        ),
      ],
    );
  }
}

class _SubtypeDialog extends StatefulWidget {
  @override
  State<_SubtypeDialog> createState() => _SubtypeDialogState();
}

class _SubtypeDialogState extends State<_SubtypeDialog> {
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
      title: Text(l10n.subtypeNewTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.subtypeNameLabel),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionCreate),
        ),
      ],
    );
  }
}
