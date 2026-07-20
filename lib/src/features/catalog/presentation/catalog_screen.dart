import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../common/duration_format.dart';
import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import 'classification_labels.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  OperationCategory? _filter; // null = all types

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final operations = ref.watch(catalogListProvider);
    final subtypes = ref.watch(subtypesProvider).value ?? const [];
    final subtypeById = {for (final s in subtypes) s.id: s};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCatalog)),
      body: operations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.catalogEmpty));
          }
          final filtered = _filter == null
              ? items
              : items.where((o) => o.category == _filter).toList();
          return Column(
            children: [
              _FilterBar(
                selected: _filter,
                onSelected: (c) => setState(() => _filter = c),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final op = filtered[index];
                    return ListTile(
                      title: Text(op.name),
                      subtitle: Text(
                        _subtitle(l10n, op, subtypeById[op.subtypeId]),
                      ),
                      trailing: PopupMenuButton<_Action>(
                        onSelected: (action) => switch (action) {
                          _Action.edit =>
                            context.push('/catalog/edit/${op.id}'),
                          _Action.delete => _delete(context, op),
                        },
                        itemBuilder: (context) => [
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
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/catalog/new'),
        tooltip: l10n.catalogNewTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _subtitle(
    AppLocalizations l10n,
    CatalogOperation op,
    OperationSubtype? subtype,
  ) {
    final parts = <String>[categoryLabel(l10n, op.category)];
    if (subtype != null) parts.add(subtypeName(l10n, subtype));
    if (op.referenceStandardMs != null) {
      parts.add(formatHmsd(op.referenceStandardMs!));
    }
    return parts.join(' · ');
  }

  Future<void> _delete(BuildContext context, CatalogOperation op) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteOperationTitle,
      message: l10n.deleteOperationMessage(op.name),
    );
    if (!confirmed) return;
    await ref.read(catalogRepositoryProvider).delete(op.id);
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final OperationCategory? selected;
  final ValueChanged<OperationCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(l10n.filterAll),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final c in OperationCategory.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(categoryLabel(l10n, c)),
              selected: selected == c,
              onSelected: (_) => onSelected(c),
            ),
          ],
        ],
      ),
    );
  }
}

enum _Action { edit, delete }
