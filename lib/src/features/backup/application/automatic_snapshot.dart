import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../diagnostics/application/diagnostics.dart';
import 'backup_providers.dart';

/// Takes the daily database snapshot, if one is due.
///
/// Called once per launch and deliberately fire-and-forget: a snapshot must
/// never delay a launch, and must never be the reason one fails. Whether it ran
/// lands in the diagnostics log, so a data-loss report can be answered with
/// "there is a copy from yesterday" instead of a guess.
Future<void> takeStartupSnapshot(WidgetRef ref) async {
  try {
    final file = await ref.read(backupServiceProvider).snapshotIfDue();
    if (file != null) Diag.event('snapshot', p.basename(file.path));
  } catch (error, stack) {
    Diag.error('snapshot', error, stack);
  }
}
