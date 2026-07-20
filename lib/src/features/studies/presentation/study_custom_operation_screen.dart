import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/duration_input.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/studies_providers.dart';

/// Adds a study-local operation that isn't in the catalog.
class StudyCustomOperationScreen extends ConsumerStatefulWidget {
  const StudyCustomOperationScreen({super.key, required this.studyId});

  final String studyId;

  @override
  ConsumerState<StudyCustomOperationScreen> createState() =>
      _StudyCustomOperationScreenState();
}

class _StudyCustomOperationScreenState
    extends ConsumerState<StudyCustomOperationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  OperationCategory _category = OperationCategory.productive;
  String? _subtypeId;
  int? _referenceStandardMs;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _addSubtype() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _SubtypeDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    final created = await ref
        .read(catalogRepositoryProvider)
        .createSubtype(category: _category, name: name.trim());
    if (mounted) setState(() => _subtypeId = created.id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(studyOperationRepositoryProvider).addCustom(
          studyId: widget.studyId,
          name: _name.text.trim(),
          category: _category,
          subtypeId: _subtypeId,
          referenceStandardMs: _referenceStandardMs,
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allSubtypes = ref.watch(subtypesProvider).value ?? const [];
    final subtypesForCategory =
        allSubtypes.where((s) => s.category == _category).toList();
    final currentSubtype =
        subtypesForCategory.any((s) => s.id == _subtypeId) ? _subtypeId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customOperationTitle),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.actionSave)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.operationNameLabel),
              validator: (v) => (v == null || v.trim().isEmpty) ? '' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<OperationCategory>(
              initialValue: _category,
              decoration:
                  InputDecoration(labelText: l10n.operationCategoryLabel),
              items: [
                for (final c in OperationCategory.values)
                  DropdownMenuItem(
                    value: c,
                    child: Text(categoryLabel(l10n, c)),
                  ),
              ],
              onChanged: (c) => setState(() {
                _category = c ?? _category;
                _subtypeId = null;
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
                    onChanged: (v) => setState(() => _subtypeId = v),
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
              initialMs: _referenceStandardMs,
              onChanged: (ms) => _referenceStandardMs = ms,
            ),
          ],
        ),
      ),
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
