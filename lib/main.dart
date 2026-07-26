import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app/app.dart';
import 'src/app/window_geometry.dart';
import 'src/app/window_geometry_observer.dart';
import 'src/features/diagnostics/application/diagnostics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads intl's date symbols for every locale up front. Exports format dates
  // for the app locale outside the widget tree (DESIGN.md §5, §7), so we cannot
  // rely on the symbols flutter_localizations lazily loads for the active one.
  await initializeDateFormatting();
  // First, so the session header precedes anything worth logging and the error
  // hooks are in place before any code that could trip them (DESIGN.md §10).
  await Diag.install();

  // Desktop only: Windows does not remember a window's size, position or
  // maximised state for an application, so the app does it (DESIGN.md §10).
  // Mobile has no window to place.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    final windowObserver = WindowGeometryObserver();
    windowManager.addListener(windowObserver);
    // Before runApp, so the window is placed while it is still hidden and the
    // runner's first-frame callback reveals it already in the right spot.
    // Seeding the observer matters: a user whose first action is to maximise has
    // no stored frame yet, and without one there would be nothing to pair the
    // maximised flag with — so nothing would be saved at all.
    windowObserver.rememberNormalBounds(await WindowGeometry.restore());
  }

  runApp(
    const ProviderScope(
      observers: [DiagnosticsObserver()],
      child: ChronusApp(),
    ),
  );
}
