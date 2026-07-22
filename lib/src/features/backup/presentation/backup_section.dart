import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/confirm_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../export/application/export_delivery.dart';
import '../../export/application/export_providers.dart';
import '../application/backup_providers.dart';
import '../data/backup_bundle.dart';

/// Settings rows for the `.chronus` backup bundle — the only protection
/// against device loss in a local-first app with no accounts (DESIGN.md §2).
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            l10n.settingsDataSection,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.save_alt),
          title: Text(l10n.backupAction),
          subtitle: Text(l10n.backupSubtitle),
          enabled: !_busy,
          onTap: _busy ? null : _backUp,
        ),
        ListTile(
          leading: const Icon(Icons.settings_backup_restore),
          title: Text(l10n.restoreAction),
          subtitle: Text(l10n.restoreSubtitle),
          enabled: !_busy,
          onTap: _busy ? null : _restore,
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Future<void> _backUp() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _busy = true);
    try {
      final bytes = await ref.read(backupServiceProvider).export();
      final stamp = DateFormat('yyyy-MM-dd-HHmm').format(DateTime.now());
      final result = await ref.read(exportDeliveryProvider).deliver(
            bytes: bytes,
            fileName: 'chronus-$stamp.$bundleExtension',
            format: ExportFormat.chronus,
          );
      if (result == ExportResult.delivered) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.backupDone)));
      }
    } catch (error) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.exportFailed('$error'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final picked = await fs.openFile(acceptedTypeGroups: [
      const fs.XTypeGroup(label: 'Chronus', extensions: [bundleExtension]),
    ]);
    if (picked == null || !mounted) return;

    // Confirm only after a file is chosen, so the warning names a real action
    // rather than a hypothetical one.
    final confirmed = await confirmDelete(
      context,
      title: l10n.restoreConfirmTitle,
      message: l10n.restoreConfirmMessage,
      confirmLabel: l10n.restoreAction,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      final bytes = await File(picked.path).readAsBytes();
      final manifest = await ref.read(backupServiceProvider).import(bytes);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.restoreDone(
            DateFormat.yMMMd().add_Hm().format(manifest.createdAt))),
      ));
    } on BackupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_explain(l10n, e))));
    } catch (error) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.exportFailed('$error'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Turns a typed failure into something actionable. Every one of these
  /// happens before any data is touched, so "nothing was changed" is always
  /// true when the user sees them.
  String _explain(AppLocalizations l10n, BackupException e) =>
      switch (e.problem) {
        BackupProblem.notAZip => l10n.restoreErrorNotBundle,
        BackupProblem.missingManifest ||
        BackupProblem.missingDatabase =>
          l10n.restoreErrorDamaged,
        BackupProblem.formatTooNew ||
        BackupProblem.schemaTooNew =>
          l10n.restoreErrorTooNew,
      };
}
