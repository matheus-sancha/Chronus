import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads intl's date symbols for every locale up front. Exports format dates
  // for the app locale outside the widget tree (DESIGN.md §5, §7), so we cannot
  // rely on the symbols flutter_localizations lazily loads for the active one.
  await initializeDateFormatting();
  runApp(const ProviderScope(child: ChronusApp()));
}
