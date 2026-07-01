import 'package:flutter/material.dart';

/// Cairo (bundled variable font, OFL) covers Arabic and Latin in one family —
/// RTL-friendly metrics, no runtime font download.
abstract final class OstaTypography {
  static const fontFamily = 'Cairo';

  /// Applies Cairo across the whole scale, mapping each style's
  /// [FontWeight] onto the variable font's `wght` axis so mid weights
  /// (medium/semibold) render true instances instead of synthetic bold.
  static TextTheme textTheme(TextTheme base) {
    TextStyle? style(TextStyle? s) => s?.copyWith(
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation.weight(
          (s.fontWeight ?? FontWeight.w400).value.toDouble(),
        ),
      ],
    );

    return TextTheme(
      displayLarge: style(base.displayLarge),
      displayMedium: style(base.displayMedium),
      displaySmall: style(base.displaySmall),
      headlineLarge: style(base.headlineLarge),
      headlineMedium: style(base.headlineMedium),
      headlineSmall: style(base.headlineSmall),
      titleLarge: style(base.titleLarge),
      titleMedium: style(base.titleMedium),
      titleSmall: style(base.titleSmall),
      bodyLarge: style(base.bodyLarge),
      bodyMedium: style(base.bodyMedium),
      bodySmall: style(base.bodySmall),
      labelLarge: style(base.labelLarge),
      labelMedium: style(base.labelMedium),
      labelSmall: style(base.labelSmall),
    );
  }
}
