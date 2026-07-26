import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/build_info.dart';
import '../../../data/app_directory.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../export/application/export_delivery.dart';
import '../../export/application/export_providers.dart';
import '../application/diagnostics.dart';
import 'feedback_dialog.dart';

/// Settings rows for the diagnostics channel (DESIGN.md §10).
///
/// Chronus is handed out on a zip and used where nobody is watching, so these
/// three rows are the whole feedback loop: the build a user is on, a file that
/// carries the evidence, and the folder holding their data.
class DiagnosticsSection extends ConsumerStatefulWidget {
  const DiagnosticsSection({super.key});

  @override
  ConsumerState<DiagnosticsSection> createState() => _DiagnosticsSectionState();
}

class _DiagnosticsSectionState extends ConsumerState<DiagnosticsSection> {
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
            l10n.settingsDiagnosticsSection,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.diagnosticsBuild),
          // The one string that turns "it did something weird" into a commit.
          subtitle: Text(kBuildLabel),
        ),
        ListTile(
          leading: const Icon(Icons.feedback_outlined),
          title: Text(l10n.feedbackAction),
          subtitle: Text(l10n.feedbackSubtitle),
          onTap: () => showFeedbackDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: Text(l10n.diagnosticsSave),
          subtitle: Text(l10n.diagnosticsSaveSubtitle),
          enabled: !_busy,
          onTap: _busy ? null : _saveDiagnostics,
        ),
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: Text(l10n.diagnosticsOpenFolder),
          subtitle: Text(l10n.diagnosticsOpenFolderSubtitle),
          onTap: _openDataFolder,
        ),
      ],
    );
  }

  /// Writes the log plus any feedback out through the same save-file dialog the
  /// exports use.
  ///
  /// The suggested name carries the build label and the machine name on purpose:
  /// several colleagues sending back a file called `log.txt` would arrive
  /// indistinguishable, and renaming them by hand as they trickle in is exactly
  /// the sort of bookkeeping that stops getting done.
  Future<void> _saveDiagnostics() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final log = Diag.log;
    if (log == null) return;

    setState(() => _busy = true);
    try {
      await log.flush();
      final text = await log.compose(buildLabel: kBuildLabel);
      final result = await ref.read(exportDeliveryProvider).deliver(
            bytes: Uint8List.fromList(utf8.encode(text)),
            fileName: 'chronus-log-$kBuildLabel-${_machine()}.txt',
            format: ExportFormat.text,
          );
      if (result == ExportResult.delivered) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.diagnosticsSaved)));
      }
    } catch (error) {
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.exportFailed('$error'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Reveals the app data directory. Also the honest answer to "where are my
  /// backups?" — the data deliberately does not live beside the .exe
  /// (see `app_directory.dart`), so without this the user has to be told to
  /// paste a %APPDATA% path into Explorer.
  Future<void> _openDataFolder() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dir = await appDataDirectory();
      await dir.create(recursive: true);
      if (Platform.isWindows) {
        await Process.start('explorer.exe', [dir.path]);
      } else if (Platform.isMacOS) {
        await Process.start('open', [dir.path]);
      }
    } catch (error) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.diagnosticsFolderFailed('$error'))));
    }
  }

  /// Machine name, reduced to what is safe in a file name.
  String _machine() {
    try {
      final raw = Platform.localHostname;
      final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9\-_]'), '');
      return safe.isEmpty ? 'pc' : safe;
    } catch (_) {
      return 'pc';
    }
  }
}
