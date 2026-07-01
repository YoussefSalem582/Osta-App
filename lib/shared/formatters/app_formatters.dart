import 'package:intl/intl.dart';

/// Pins bare language codes to the Egypt market variant — plain `ar` renders
/// Latin digits in CLDR, while `ar_EG` gives Arabic-Indic digits.
String _marketLocale(String locale) {
  if (locale.contains('_')) return locale;
  return locale.startsWith('ar') ? 'ar_EG' : 'en_EG';
}

/// EGP currency formatting — Arabic-Indic digits + «ج.م.» under `ar`,
/// Latin digits + EGP under `en`. Currency is fixed to EGP in M0.
abstract final class EgpFormatter {
  static String _symbol(String locale) =>
      locale.startsWith('ar') ? 'ج.م.' : 'EGP ';

  /// e.g. `format(1250.5, locale: 'ar')` → `١٬٢٥٠٫٥٠ ج.م.`
  static String format(num amount, {required String locale}) =>
      NumberFormat.currency(
        locale: _marketLocale(locale),
        symbol: _symbol(locale),
      ).format(amount);

  /// Compact form for cards/badges, e.g. `EGP 12.5K`.
  static String compact(num amount, {required String locale}) =>
      NumberFormat.compactCurrency(
        locale: _marketLocale(locale),
        symbol: _symbol(locale),
      ).format(amount);
}

/// Plain number formatting following the active locale (Egypt digits).
abstract final class NumberFormatter {
  static String decimal(num value, {required String locale}) =>
      NumberFormat.decimalPattern(_marketLocale(locale)).format(value);

  static String compact(num value, {required String locale}) =>
      NumberFormat.compact(locale: _marketLocale(locale)).format(value);

  static String percent(double fraction, {required String locale}) =>
      NumberFormat.percentPattern(_marketLocale(locale)).format(fraction);
}
