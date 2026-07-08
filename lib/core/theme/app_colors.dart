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

  // --- Light neutrals & brand tints ---------------------------------------
  // `ColorScheme.fromSeed` renders the light neutrals flat and the primary a
  // muted olive; these tuned tokens restore the brand green and give the
  // surfaces a soft green-grey depth (white cards + tinted input fields on a
  // slightly darker background).
  static const lightBackground = Color(0xFFF1F5F2); // scaffold + app bar
  static const lightSurface = Color(0xFFFFFFFF); // cards, sheets
  static const lightSurfaceAlt = Color(0xFFE8EFEA); // input fill, sections
  static const lightOnSurface = Color(0xFF171D19); // near-black, green-tinted
  static const lightOutline = Color(0xFFDBE3DD); // hairline dividers/borders
  static const lightPrimaryContainer = Color(0xFFCDEBD6); // soft brand tint
  static const onLightPrimaryContainer = Color(0xFF06331A);

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
