import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/backup/application/automatic_snapshot.dart';
import '../features/studies/presentation/orphaned_timing_prompt.dart';
import '../l10n/generated/app_localizations.dart';

/// The persistent navigation chrome around the top-level destinations.
///
/// Responsive by design (rehearses the Windows story): a bottom [NavigationBar]
/// on phone-width, a side [NavigationRail] once there's room. The branch state
/// is preserved across switches by go_router's [StatefulNavigationShell].
///
/// It also owns the once-per-launch check for timers left running (see
/// [promptForOrphanedTiming]) — not because startup checks belong in navigation
/// chrome, but because this is the outermost widget guaranteed to sit below a
/// Navigator, which `showDialog` requires.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _railBreakpoint = 720.0;

  @override
  void initState() {
    super.initState();
    // After the first frame: the shell must be mounted and painted before a
    // dialog goes over it, or the analyst sees a question with no context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      promptForOrphanedTiming(context, ref);
      // Unawaited on purpose, and after the prompt: a background copy must not
      // hold up the UI, and neither task depends on the other.
      takeStartupSnapshot(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final l10n = AppLocalizations.of(context);
    final destinations = <_Destination>[
      _Destination(Icons.folder_outlined, Icons.folder, l10n.navProjects),
      _Destination(Icons.build_outlined, Icons.build, l10n.navCatalog),
      _Destination(Icons.description_outlined, Icons.description,
          l10n.navTemplates),
      _Destination(Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];

    void onSelect(int index) {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= _railBreakpoint;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: onSelect,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
