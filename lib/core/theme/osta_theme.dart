import 'package:flutter/material.dart';
import 'package:osta/core/theme/osta_colors.dart';
import 'package:osta/core/theme/osta_tokens.dart';
import 'package:osta/core/theme/osta_typography.dart';

/// Osta Material 3 themes — the single source every screen renders from.
///
/// Both shells (customer + provider) use these; no hardcoded colors outside
/// the token layer ([OstaColors], [OstaSpacing], [OstaRadii], [OstaElevation]).
abstract final class OstaTheme {
  static ThemeData light() => _build(Brightness.light, OstaColors.light);

  static ThemeData dark() => _build(Brightness.dark, OstaColors.dark);

  static ThemeData _build(Brightness brightness, OstaColors tokens) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: OstaColors.brandGreen,
          brightness: brightness,
        ).copyWith(
          secondary: tokens.accent,
          onSecondary: tokens.onAccent,
        );
    final base = ThemeData(colorScheme: scheme);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(OstaRadii.md),
    );
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: OstaSpacing.lg,
      vertical: OstaSpacing.md,
    );

    return base.copyWith(
      textTheme: OstaTypography.textTheme(base.textTheme),
      extensions: [tokens],
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: OstaElevation.none,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: buttonShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OstaRadii.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OstaSpacing.md,
          vertical: OstaSpacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: OstaElevation.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OstaRadii.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OstaRadii.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OstaRadii.md),
        ),
      ),
    );
  }
}
