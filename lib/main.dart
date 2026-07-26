import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app/app.dart';
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
  runApp(
    const ProviderScope(
      observers: [DiagnosticsObserver()],
      child: ChronusApp(),
    ),
  );
}
