import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import 'classification_labels.dart';

/// What the add-operation sheet returned.
sealed class OperationPick {}

class PickCatalog extends OperationPick {
  PickCatalog(this.operation);
  final CatalogOperation operation;
}

class PickCustom extends OperationPick {}

/// Add-operation sheet: search by name, filter by type, pick a catalog
/// operation, or choose "Custom operation". Returns null if dismissed.
Future<OperationPick?> showOperationPicker(BuildContext context) {
  return showModalBottomSheet<OperationPick>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _OperationPickerSheet(),
  );
}

class _OperationPickerSheet extends ConsumerStatefulWidget {
  const _OperationPickerSheet();

  @override
  ConsumerState<_OperationPickerSheet> createState() =>
      _OperationPickerSheetState();
}

class _OperationPickerSheetState extends ConsumerState<_OperationPickerSheet> {
  final _search = TextEditingController();
  OperationCategory? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(catalogListProvider).value ?? const [];
    final query = _search.text.trim().toLowerCase();
    final filtered = catalog.where((op) {
      final matchesType = _filter == null || op.category == _filter;
      final matchesQuery =
          query.isEmpty || op.name.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();

    final maxListHeight = MediaQuery.sizeOf(context).height * 0.5;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.addOperationTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: Text(l10n.customOperationTitle),
              onTap: () => Navigator.of(context).pop(PickCustom()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.filterAll),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final c in OperationCategory.values) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(categoryLabel(l10n, c)),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(l10n.catalogPickerEmpty)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxListHeight),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final op = filtered[index];
                    return ListTile(
                      title: Text(op.name),
                      subtitle: Text(categoryLabel(l10n, op.category)),
                      onTap: () => Navigator.of(context).pop(PickCatalog(op)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
