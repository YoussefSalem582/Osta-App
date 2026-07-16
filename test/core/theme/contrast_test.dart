import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/theme/app_colors.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) {
    final s = v / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * channel(c.r * 255) +
      0.7152 * channel(c.g * 255) +
      0.0722 * channel(c.b * 255);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // WCAG AA for normal-size text.
  const aa = 4.5;

  group('semantic on/background pairs meet WCAG AA', () {
    for (final (name, scheme) in [
      ('light', AppColors.light),
      ('dark', AppColors.dark),
    ]) {
      test('$name: onSuccess on success', () {
        // tech_screen painted this label #3A694E on success, scoring 1.12:1 in
        // light — effectively invisible. It uses onSuccess now.
        expect(contrast(scheme.onSuccess, scheme.success), greaterThan(aa));
      });

      test('$name: onWarning on warning', () {
        expect(contrast(scheme.onWarning, scheme.warning), greaterThan(aa));
      });

      test('$name: onAccent on accent', () {
        expect(contrast(scheme.onAccent, scheme.accent), greaterThan(aa));
      });
    }
  });

  test('the contrast helper itself is sane', () {
    expect(contrast(const Color(0xFFFFFFFF), const Color(0xFF000000)), 21);
    expect(contrast(const Color(0xFF123456), const Color(0xFF123456)), 1);
    // The exact pairing the bug was about.
    expect(
      contrast(const Color(0xFF3A694E), const Color(0xFF166534)),
      lessThan(aa),
      reason: 'the old hardcoded green really did fail AA',
    );
  });
}
