import 'package:flutter/material.dart';

/// Light/dark Material 3 themes seeded from the OSTA brand colour.
abstract final class AppTheme {
  static const _seed = Color(0xFF0EA5A6);

  static ThemeData get light =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed));

  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
