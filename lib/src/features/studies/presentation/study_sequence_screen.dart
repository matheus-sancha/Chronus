import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/duration_format.dart';
import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../../catalog/presentation/operation_picker.dart';
import '../application/studies_providers.dart';

/// Build a study's operation sequence: add from the catalog (or a custom
/// operation), drag to reorder, remove. Timing comes in Phase 3.
class StudySequenceScreen extends ConsumerWidget {
  const StudySequenceScreen({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final operations = ref.watch(studyOperationsProvider(studyId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyOperationsSection)),
      body: operations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.sequenceEmpty));
          }
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: (oldIndex, newIndex) {
              final ids = items.map((e) => e.id).toList();
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex, moved);
              ref.read(studyOperationRepositoryProvider).reorder(ids);
            },
            itemBuilder: (context, index) {
              final op = items[index];
              return ListTile(
                key: ValueKey(op.id),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(op.name),
                subtitle: Text(_subtitle(l10n, op)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: l10n.actionDelete,
                  onPressed: () => ref
                      .read(studyOperationRepositoryProvider)
                      .remove(op.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOperation(context, ref),
        tooltip: l10n.addOperationTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _subtitle(AppLocalizations l10n, StudyOperation op) {
    final parts = <String>[categoryLabel(l10n, op.category)];
    if (op.referenceStandardMs != null) {
      parts.add(formatHmsd(op.referenceStandardMs!));
    }
    return parts.join(' · ');
  }

  Future<void> _addOperation(BuildContext context, WidgetRef ref) async {
    final pick = await showOperationPicker(context);
    switch (pick) {
      case PickCatalog(:final operation):
        await ref
            .read(studyOperationRepositoryProvider)
            .addFromCatalog(studyId: studyId, operation: operation);
      case PickCustom():
        if (context.mounted) {
          context.push('/projects/$projectId/studies/$studyId/sequence/custom');
        }
      case null:
        break;
    }
  }
}
