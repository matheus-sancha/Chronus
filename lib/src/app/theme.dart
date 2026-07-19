import 'package:flutter/material.dart';

/// App theming. Single seed color for now (placeholder brand); Material 3.
class ChronusTheme {
  const ChronusTheme._();

  static const Color _seed = Color(0xFF00696E);

  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      );

  static ThemeData dark() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
