import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../diagnostics/application/diagnostics.dart';
import '../application/timing_providers.dart';
import '../data/timing_repository.dart';

/// Asks about timers that were still running when the app last closed.
///
/// Runs once per launch, from the navigation shell (which is safely below a
/// Navigator, unlike `MaterialApp.builder`). It has to be a prompt rather than a
/// silent repair: discarding measured-looking time without saying so would be
/// its own kind of wrong, and only the analyst knows whether a long-running
/// machine cycle is legitimately still going.
///
/// See [TimingRepository.orphanedTiming] for why abandoned segments are a hazard
/// and [TimingRepository.discardOrphanedTiming] for why the fix is a delete.
Future<void> promptForOrphanedTiming(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(timingRepositoryProvider);

  OrphanedTiming? found;
  try {
    found = await repo.orphanedTiming();
  } catch (error, stack) {
    // Nothing here is worth failing a launch over: a database that cannot be
    // queried has bigger problems, and they will surface on the first screen
    // that needs it, with a log entry to go with them.
    Diag.error('orphan.check', error, stack);
    return;
  }
  if (found == null || !context.mounted) return;
  // Rebound non-nullable, because the dialog builder is a closure and a
  // promoted local does not survive capture.
  final orphaned = found;

  final l10n = AppLocalizations.of(context);
  final discard = await showDialog<bool>(
    context: context,
    // Not dismissible: a stray tap outside would silently choose "keep timing",
    // which is the option that leaves wrong numbers in a report.
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.timer_off_outlined),
      title: Text(l10n.orphanedTimingTitle),
      content: Text(l10n.orphanedTimingMessage(
        orphaned.operations,
        DateFormat.yMMMd().add_Hm().format(orphaned.since),
      )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.orphanedTimingKeep),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.orphanedTimingDiscard),
        ),
      ],
    ),
  );

  if (discard ?? false) await repo.discardOrphanedTiming();
}
