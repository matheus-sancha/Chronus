import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/duration_format.dart';
import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/catalog_picker.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/templates_providers.dart';
import 'template_instantiate.dart';

class TemplateSequenceScreen extends ConsumerWidget {
  const TemplateSequenceScreen({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final template = ref.watch(templateByIdProvider(templateId));
    final operations = ref.watch(templateOperationsProvider(templateId));
    final catalog = ref.watch(catalogListProvider).value ?? const [];
    final catalogById = {for (final c in catalog) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(template.value?.name ?? l10n.navTemplates),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: l10n.createStudyAction,
            onPressed: template.hasValue
                ? () => instantiateTemplateFlow(context, ref, template.value!)
                : null,
          ),
        ],
      ),
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
              ref.read(templateRepositoryProvider).reorderOperations(ids);
            },
            itemBuilder: (context, index) {
              final op = items[index];
              final catalogOp = catalogById[op.catalogOperationId];
              return ListTile(
                key: ValueKey(op.id),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(catalogOp?.name ?? '—'),
                subtitle: catalogOp == null
                    ? null
                    : Text(_subtitle(l10n, catalogOp)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: l10n.actionDelete,
                  onPressed: () =>
                      ref.read(templateRepositoryProvider).removeOperation(op.id),
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

  String _subtitle(AppLocalizations l10n, CatalogOperation catalogOp) {
    final parts = <String>[categoryLabel(l10n, catalogOp.category)];
    if (catalogOp.referenceStandardMs != null) {
      parts.add(formatHmsd(catalogOp.referenceStandardMs!));
    }
    return parts.join(' · ');
  }

  Future<void> _addOperation(BuildContext context, WidgetRef ref) async {
    final chosen = await showCatalogPicker(context);
    if (chosen == null) return;
    await ref.read(templateRepositoryProvider).addOperation(
          templateId: templateId,
          catalogOperationId: chosen.id,
        );
  }
}
