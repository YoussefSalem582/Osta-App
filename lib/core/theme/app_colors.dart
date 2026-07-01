import 'package:flutter/material.dart';

/// Osta brand + semantic color tokens.
///
/// The only place hex values may live. [ColorScheme] (seeded from
/// [brandGreen]) covers primary/surface/error roles; this extension carries
/// the custom semantic roles the scheme lacks, split per light & dark.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  /// Brand seed — Osta green.
  static const brandGreen = Color(0xFF0E7A3B);

  /// Brand accent — Osta lime.
  static const brandLime = Color(0xFFB2D235);

  static const light = AppColors(
    accent: brandLime,
    onAccent: Color(0xFF1A2E05),
    success: Color(0xFF166534),
    onSuccess: Colors.white,
    warning: Color(0xFF92400E),
    onWarning: Colors.white,
  );

  static const dark = AppColors(
    accent: brandLime,
    onAccent: Color(0xFF1A2E05),
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF451A03),
  );

  final Color accent;
  final Color onAccent;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  @override
  AppColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) => AppColors(
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}

/// Shortcut: `context.appColors.success`.
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
