import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';

String categoryLabel(AppLocalizations l10n, OperationCategory category) =>
    switch (category) {
      OperationCategory.setup => l10n.categorySetup,
      OperationCategory.productive => l10n.categoryProductive,
      OperationCategory.unproductive => l10n.categoryUnproductive,
    };

/// Built-in subtypes are seeded with canonical English names, so localize those;
/// user-created subtypes display their stored name verbatim.
String subtypeName(AppLocalizations l10n, OperationSubtype subtype) {
  if (!subtype.isBuiltIn) return subtype.name;
  return switch (subtype.name) {
    'Waiting' => l10n.wasteWaiting,
    'Motion' => l10n.wasteMotion,
    'Transportation' => l10n.wasteTransportation,
    'Over-processing' => l10n.wasteOverProcessing,
    'Overproduction' => l10n.wasteOverproduction,
    'Inventory' => l10n.wasteInventory,
    'Defects' => l10n.wasteDefects,
    _ => subtype.name,
  };
}
