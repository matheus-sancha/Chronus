import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../backup/presentation/backup_section.dart';
import '../application/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (settings) {
          final repo = ref.read(settingsRepositoryProvider);
          final analyst = settings.defaultAnalyst;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.settingsLanguage),
                subtitle: Text(_localeLabel(l10n, settings.localeCode)),
                onTap: () => _pickLanguage(
                  context,
                  l10n,
                  settings.localeCode,
                  repo.setLocaleCode,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.settingsAnalyst),
                subtitle: Text(
                  (analyst != null && analyst.isNotEmpty)
                      ? analyst
                      : l10n.settingsAnalystEmpty,
                ),
                onTap: () => _editAnalyst(
                  context,
                  l10n,
                  analyst,
                  repo.setDefaultAnalyst,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.settingsUnit),
                subtitle: Text(_unitLabel(l10n, settings.timeUnit)),
                onTap: () => _pickUnit(
                  context,
                  l10n,
                  settings.timeUnit,
                  repo.setTimeUnit,
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.settingsAlertSounds),
                subtitle: Text(l10n.settingsAlertSoundsSubtitle),
                value: settings.alertSoundsEnabled,
                onChanged: repo.setAlertSoundsEnabled,
              ),
              const BackupSection(),
            ],
          );
        },
      ),
    );
  }

  String _localeLabel(AppLocalizations l10n, String? code) {
    // Language names are shown natively (untranslated) by convention.
    switch (code) {
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'es':
        return 'Español';
      default:
        return l10n.settingsLanguageSystem;
    }
  }

  String _unitLabel(AppLocalizations l10n, TimeUnit unit) {
    return switch (unit) {
      TimeUnit.seconds => l10n.settingsUnitSeconds,
      TimeUnit.decimalMinutes => l10n.settingsUnitDecimalMinutes,
    };
  }

  Future<void> _pickLanguage(
    BuildContext context,
    AppLocalizations l10n,
    String? current,
    Future<void> Function(String?) onPick,
  ) {
    final options = <(String?, String)>[
      (null, l10n.settingsLanguageSystem),
      ('en', 'English'),
      ('pt', 'Português'),
      ('es', 'Español'),
    ];
    return _chooseFromList(
      context,
      title: l10n.settingsLanguage,
      options: options,
      current: current,
      onPick: onPick,
    );
  }

  Future<void> _pickUnit(
    BuildContext context,
    AppLocalizations l10n,
    TimeUnit current,
    Future<void> Function(TimeUnit) onPick,
  ) {
    final options = <(TimeUnit, String)>[
      (TimeUnit.seconds, l10n.settingsUnitSeconds),
      (TimeUnit.decimalMinutes, l10n.settingsUnitDecimalMinutes),
    ];
    return _chooseFromList(
      context,
      title: l10n.settingsUnit,
      options: options,
      current: current,
      onPick: onPick,
    );
  }

  /// A simple single-select dialog: tapping an option applies it and closes.
  /// (Avoids the deprecated Radio grouped-value API.)
  Future<void> _chooseFromList<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T current,
    required Future<void> Function(T) onPick,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: [
          for (final (value, label) in options)
            ListTile(
              title: Text(label),
              trailing: value == current ? const Icon(Icons.check) : null,
              onTap: () {
                onPick(value);
                Navigator.of(dialogContext).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _editAnalyst(
    BuildContext context,
    AppLocalizations l10n,
    String? current,
    Future<void> Function(String?) onSave,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _AnalystDialog(initial: current),
    );
    if (value == null) return; // cancelled
    final trimmed = value.trim();
    await onSave(trimmed.isEmpty ? null : trimmed);
  }
}

class _AnalystDialog extends StatefulWidget {
  const _AnalystDialog({this.initial});

  final String? initial;

  @override
  State<_AnalystDialog> createState() => _AnalystDialogState();
}

class _AnalystDialogState extends State<_AnalystDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.settingsAnalyst),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
