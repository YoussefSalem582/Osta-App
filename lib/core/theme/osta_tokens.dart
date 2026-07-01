/// Non-color design tokens: spacing, radii, elevation.
///
/// Components and screens must use these instead of magic numbers.
library;

abstract final class OstaSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class OstaRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

abstract final class OstaElevation {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 3;
  static const double high = 6;
}
