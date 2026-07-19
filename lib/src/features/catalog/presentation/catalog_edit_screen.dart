import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import 'classification_labels.dart';

/// Create/edit a catalog operation. [operationId] null => create.
class CatalogEditScreen extends ConsumerStatefulWidget {
  const CatalogEditScreen({super.key, this.operationId});

  final String? operationId;

  @override
  ConsumerState<CatalogEditScreen> createState() => _CatalogEditScreenState();
}

class _CatalogEditScreenState extends ConsumerState<CatalogEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _referenceStandard = TextEditingController();

  OperationCategory _category = OperationCategory.productive;
  String? _subtypeId;
  bool _initialized = false;

  bool get _isEditing => widget.operationId != null;

  @override
  void initState() {
    super.initState();
    if (!_isEditing) _initialized = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _referenceStandard.dispose();
    super.dispose();
  }

  void _hydrate(CatalogOperation op) {
    _name.text = op.name;
    _category = op.category;
    _subtypeId = op.subtypeId;
    if (op.referenceStandardMs != null) {
      _referenceStandard.text = _formatSeconds(op.referenceStandardMs!);
    }
    _initialized = true;
  }

  static String _formatSeconds(int ms) {
    final seconds = ms / 1000;
    return seconds == seconds.roundToDouble()
        ? seconds.toStringAsFixed(0)
        : seconds.toString();
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
    final seconds =
        double.tryParse(_referenceStandard.text.trim().replaceAll(',', '.'));
    final referenceStandardMs =
        seconds == null ? null : (seconds * 1000).round();
    final repo = ref.read(catalogRepositoryProvider);
    if (_isEditing) {
      await repo.update(
        id: widget.operationId!,
        name: _name.text.trim(),
        category: _category,
        subtypeId: _subtypeId,
        referenceStandardMs: referenceStandardMs,
      );
    } else {
      await repo.create(
        name: _name.text.trim(),
        category: _category,
        subtypeId: _subtypeId,
        referenceStandardMs: referenceStandardMs,
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtypesAsync = ref.watch(subtypesProvider);

    Widget form() => _form(l10n, subtypesAsync.value ?? const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.catalogEditTitle : l10n.catalogNewTitle),
        actions: [
          TextButton(
            onPressed: _initialized ? _save : null,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: _isEditing
          ? ref.watch(catalogByIdProvider(widget.operationId!)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
                data: (op) {
                  if (!_initialized) _hydrate(op);
                  return form();
                },
              )
          : form(),
    );
  }

  Widget _form(AppLocalizations l10n, List<OperationSubtype> allSubtypes) {
    final subtypesForCategory =
        allSubtypes.where((s) => s.category == _category).toList();
    final currentSubtype =
        subtypesForCategory.any((s) => s.id == _subtypeId) ? _subtypeId : null;

    return Form(
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
                DropdownMenuItem(value: c, child: Text(categoryLabel(l10n, c))),
            ],
            onChanged: (c) => setState(() {
              _category = c ?? _category;
              _subtypeId = null; // subtypes are category-scoped
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
          TextFormField(
            controller: _referenceStandard,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.operationReferenceStandardLabel,
            ),
          ),
        ],
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
