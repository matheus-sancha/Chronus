import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/catalog/presentation/operation_fields.dart';
import '../../../l10n/generated/app_localizations.dart';
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
  final _draft = OperationDraft();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_draft.name.isEmpty) return;
    await ref.read(studyOperationRepositoryProvider).addCustom(
          studyId: widget.studyId,
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
