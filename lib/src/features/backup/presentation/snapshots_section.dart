import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/confirm_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/backup_providers.dart';
import '../application/backup_service.dart';

/// The automatic snapshots, listed so a user can recover without a phone call.
///
/// The snapshots themselves are silent (DESIGN.md §10) — nothing nags, nothing
/// asks. This section exists only for the day one is needed: restoring by hand
/// would mean replacing `chronus.sqlite` in `%APPDATA%` and remembering to
/// delete the `-wal` and `-shm` sidecars too, and a stale `-wal` beside a
/// replaced database can corrupt it. One guarded button removes that footgun.
///
/// Renders nothing until a snapshot exists, so a fresh install shows no
/// mysterious empty list.
class SnapshotsSection extends ConsumerStatefulWidget {
  const SnapshotsSection({super.key});

  @override
  ConsumerState<SnapshotsSection> createState() => _SnapshotsSectionState();
}

class _SnapshotsSectionState extends ConsumerState<SnapshotsSection> {
  late Future<List<File>> _snapshots = _load();
  bool _busy = false;

  Future<List<File>> _load() => ref.read(backupServiceProvider).listSnapshots();

  void _reload() => setState(() => _snapshots = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<File>>(
      future: _snapshots,
      builder: (context, snapshot) {
        final files = snapshot.data ?? const <File>[];
        if (files.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                l10n.snapshotsTitle,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.snapshotsSubtitle,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            for (final file in files)
              ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(_when(file)),
                trailing: TextButton(
                  onPressed: _busy ? null : () => _restore(file),
                  child: Text(l10n.restoreAction),
                ),
              ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(),
              ),
          ],
        );
      },
    );
  }

  /// From the file name, not its mtime — a copied folder resets mtimes, and the
  /// name is the only record of when the snapshot was really taken.
  String _when(File file) {
    final taken =
        BackupService.snapshotTakenAt(file) ?? file.statSync().modified;
    return DateFormat.yMMMd().add_Hm().format(taken);
  }

  Future<void> _restore(File file) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final when = _when(file);

    // Confirmed for the same reason a bundle restore is: it is total as to rows.
    // The message says photos are untouched, because that differs from the
    // bundle restore right above it and the difference matters.
    final confirmed = await confirmDelete(
      context,
      title: l10n.snapshotRestoreConfirmTitle,
      message: l10n.snapshotRestoreConfirmMessage(when),
      confirmLabel: l10n.restoreAction,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).restoreSnapshot(file);
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.snapshotRestoreDone(when))));
    } catch (error) {
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.exportFailed('$error'))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _reload();
      }
    }
  }
}
