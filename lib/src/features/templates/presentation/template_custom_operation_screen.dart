import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/catalog/presentation/operation_fields.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/templates_providers.dart';

/// Adds a template-local operation that isn't in the catalog.
class TemplateCustomOperationScreen extends ConsumerStatefulWidget {
  const TemplateCustomOperationScreen({super.key, required this.templateId});

  final String templateId;

  @override
  ConsumerState<TemplateCustomOperationScreen> createState() =>
      _TemplateCustomOperationScreenState();
}

class _TemplateCustomOperationScreenState
    extends ConsumerState<TemplateCustomOperationScreen> {
  final _draft = OperationDraft();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_draft.name.isEmpty) return;
    await ref.read(templateRepositoryProvider).addCustom(
          templateId: widget.templateId,
          name: _draft.name,
          category: _draft.category,
          subtypeId: _draft.subtypeId,
          referenceStandardMs: _draft.referenceStandardMs,
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customOperationTitle),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.actionSave)),
        ],
      ),
      body: OperationFieldsForm(draft: _draft),
    );
  }
}
