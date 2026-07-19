import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Settings surface. Rows are placeholders in Phase 1; persistence (language
/// override, default analyst) is wired in a later foundations pass.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(l10n.settingsLanguageSystem),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsAnalyst),
          ),
        ],
      ),
    );
  }
}
