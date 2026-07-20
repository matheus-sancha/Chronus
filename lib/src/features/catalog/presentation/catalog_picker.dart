import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/catalog_providers.dart';
import 'classification_labels.dart';

/// Bottom sheet to pick a catalog operation. Returns the chosen operation, or
/// null if dismissed.
Future<CatalogOperation?> showCatalogPicker(BuildContext context) {
  return showModalBottomSheet<CatalogOperation>(
    context: context,
    builder: (context) => const _CatalogPickerSheet(),
  );
}

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
