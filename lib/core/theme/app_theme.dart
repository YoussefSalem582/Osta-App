import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/core/theme/app_typography.dart';

/// Osta Material 3 themes — the single source every screen renders from.
///
/// Both shells (customer + provider) use these; no hardcoded colors outside
/// the token layer ([AppColors], [AppSpacing], [AppRadii], [AppElevation]).
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static OutlineInputBorder _inputBorder(BorderSide side) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: side,
  );

  static ThemeData _build(Brightness brightness, AppColors tokens) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brandGreen,
          brightness: brightness,
        ).copyWith(
          secondary: tokens.accent,
          onSecondary: tokens.onAccent,
        );
    final base = ThemeData(colorScheme: scheme);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    );

    return base.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF4F6F5)
          : null,
      textTheme: AppTypography.textTheme(base.textTheme),
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: AppElevation.none,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFFF4F6F5)
            : null,
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
        fillColor: brightness == Brightness.light ? Colors.white : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        // Resting/enabled: flat filled, no border. Focus: a 2px brand ring.
        // Error: an error-coloured ring — clear state feedback per M3 guidance.
        border: _inputBorder(BorderSide.none),
        enabledBorder: _inputBorder(BorderSide.none),
        focusedBorder: _inputBorder(
          BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: _inputBorder(BorderSide(color: scheme.error, width: 1.5)),
        focusedErrorBorder: _inputBorder(
          BorderSide(color: scheme.error, width: 2),
        ),
        // Placeholder / resting label muted so it reads as a hint, not as
        // typed text; the floating label turns brand-coloured on focus.
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        // Leading/trailing icons tint to the brand colour while focused.
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
        suffixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light ? Colors.white : null,
        elevation: AppElevation.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }
}
