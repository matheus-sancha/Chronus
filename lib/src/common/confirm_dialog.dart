import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Shows a destructive-action confirmation. Returns true only if confirmed.
///
/// [confirmLabel] defaults to "Delete"; pass the actual verb for destructive
/// actions that are not deletions, so the button says what it will do.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? l10n.actionDelete),
        ),
      ],
    ),
  );
  return result ?? false;
}
