import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/duration_format.dart';
import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/studies_providers.dart';

/// Build a study's operation sequence: add from the catalog, drag to reorder,
/// remove. Timing (per-observation) comes in Phase 3.
class StudySequenceScreen extends ConsumerWidget {
  const StudySequenceScreen({super.key, required this.studyId});

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
    final chosen = await showModalBottomSheet<CatalogOperation>(
      context: context,
      builder: (context) => const _CatalogPickerSheet(),
    );
    if (chosen == null) return;
    await ref
        .read(studyOperationRepositoryProvider)
        .addFromCatalog(studyId: studyId, operation: chosen);
  }
}

/// Bottom sheet listing catalog operations; tap one to add it to the sequence.
class _CatalogPickerSheet extends ConsumerWidget {
  const _CatalogPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(catalogListProvider);

    return SafeArea(
      child: catalog.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text('$error')),
        ),
        data: (operations) {
          if (operations.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.catalogPickerEmpty)),
            );
          }
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.addOperationTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final op in operations)
                ListTile(
                  title: Text(op.name),
                  subtitle: Text(categoryLabel(l10n, op.category)),
                  onTap: () => Navigator.of(context).pop(op),
                ),
            ],
          );
        },
      ),
    );
  }
}
