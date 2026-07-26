import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Keyboard control for the study workspace (DESIGN.md §10.7).
///
/// The point is **eyes on the machine, not on the screen**. An analyst timing a
/// station cannot spare attention for a mouse, so the common case — a straight
/// sequential run — is one key pressed repeatedly, and the rest is reachable
/// without looking away for long.
///
/// [LapIntent] is the primary one: it drives `stopAndStartNext`, which closes the
/// current operation and opens the next at the *same instant*, so a run stays
/// gapless.
class LapIntent extends Intent {
  const LapIntent();
}

/// Move the row selection by [delta] places.
class MoveRowFocusIntent extends Intent {
  const MoveRowFocusIntent(this.delta);

  final int delta;
}

class ToggleFocusedRowIntent extends Intent {
  const ToggleFocusedRowIntent();
}

class StopFocusedRowIntent extends Intent {
  const StopFocusedRowIntent();
}

class ClearRowFocusIntent extends Intent {
  const ClearRowFocusIntent();
}

class ShowTimingShortcutsIntent extends Intent {
  const ShowTimingShortcutsIntent();
}

/// The bindings.
///
/// Placed on a `Shortcuts` widget *inside* the workspace, which matters: key
/// events resolve from the focused node upwards, so these are found before
/// `WidgetsApp`'s global defaults that map Space and Enter to activating whatever
/// button happens to be focused. Combined with the workspace excluding its row
/// controls from focus traversal, that makes Space unambiguously "lap" rather
/// than "press the button I last clicked".
///
/// **F1 only for the help sheet, no `?`.** Typing `?` needs Shift plus a key that
/// moves between layouts — on a Brazilian ABNT2 keyboard it is not where a US
/// layout puts it — and a shortcut that silently does nothing on the keyboards
/// these users actually have is worse than no shortcut. The app-bar icon is the
/// discoverable route anyway.
const timingShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.space): LapIntent(),
  SingleActivator(LogicalKeyboardKey.arrowDown): MoveRowFocusIntent(1),
  SingleActivator(LogicalKeyboardKey.arrowUp): MoveRowFocusIntent(-1),
  SingleActivator(LogicalKeyboardKey.enter): ToggleFocusedRowIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): ToggleFocusedRowIntent(),
  SingleActivator(LogicalKeyboardKey.keyS): StopFocusedRowIntent(),
  SingleActivator(LogicalKeyboardKey.escape): ClearRowFocusIntent(),
  SingleActivator(LogicalKeyboardKey.f1): ShowTimingShortcutsIntent(),
};

/// The help sheet, from F1 or the app-bar icon.
///
/// It explains *why* Space goes inert under concurrency rather than just listing
/// keys — that behaviour looks like a bug until you know it is a refusal to guess
/// which operator's timer to stop.
Future<void> showTimingShortcuts(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        icon: const Icon(Icons.keyboard_outlined),
        title: Text(l10n.shortcutsTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Shortcut(keys: l10n.shortcutsKeySpace, description: l10n.shortcutsLap),
              _Shortcut(
                  keys: l10n.shortcutsKeyArrows, description: l10n.shortcutsMove),
              _Shortcut(
                  keys: l10n.shortcutsKeyEnter, description: l10n.shortcutsToggle),
              _Shortcut(keys: l10n.shortcutsKeyS, description: l10n.shortcutsStop),
              _Shortcut(keys: l10n.shortcutsKeyEsc, description: l10n.shortcutsClear),
              const SizedBox(height: 12),
              Text(
                l10n.shortcutsConcurrencyNote,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      );
    },
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.keys, required this.description});

  final String keys;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              keys,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          Expanded(child: Text(description, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
