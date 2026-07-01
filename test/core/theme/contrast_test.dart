import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_theme.dart';

/// WCAG relative-contrast ratio between two colors.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  const aa = 4.5; // WCAG AA, normal text

  final pairs = <String, (Color, Color) Function(ThemeData)>{
    'onPrimary/primary': (t) =>
        (t.colorScheme.onPrimary, t.colorScheme.primary),
    'onSecondary/secondary': (t) =>
        (t.colorScheme.onSecondary, t.colorScheme.secondary),
    'onSurface/surface': (t) =>
        (t.colorScheme.onSurface, t.colorScheme.surface),
    'onError/error': (t) => (t.colorScheme.onError, t.colorScheme.error),
    'onAccent/accent': (t) {
      final c = t.extension<AppColors>()!;
      return (c.onAccent, c.accent);
    },
    'onSuccess/success': (t) {
      final c = t.extension<AppColors>()!;
      return (c.onSuccess, c.success);
    },
    'onWarning/warning': (t) {
      final c = t.extension<AppColors>()!;
      return (c.onWarning, c.warning);
    },
  };

  for (final (name, builder) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    group('$name theme meets WCAG AA', () {
      pairs.forEach((label, extract) {
        test(label, () {
          final (fg, bg) = extract(builder());
          final ratio = contrastRatio(fg, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(aa),
            reason: '$label ratio ${ratio.toStringAsFixed(2)} < $aa',
          );
        });
      });
    });
  }
}
