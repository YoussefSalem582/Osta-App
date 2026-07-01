import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:osta/shared/formatters/osta_formatters.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('EgpFormatter', () {
    test('ar uses Arabic-Indic digits and the EGP arabic symbol', () {
      final formatted = EgpFormatter.format(1250.5, locale: 'ar');

      expect(formatted, contains('١')); // Arabic-Indic 1
      expect(formatted, contains('ج.م')); // جنيه مصري
      expect(formatted, isNot(contains('1')));
    });

    test('en uses Latin digits', () {
      final formatted = EgpFormatter.format(1250.5, locale: 'en');

      expect(formatted, contains('1,250.50'));
      expect(formatted, isNot(contains('١')));
    });

    test('compact form abbreviates thousands', () {
      expect(EgpFormatter.compact(12500, locale: 'en'), contains('12.5K'));
    });
  });

  group('NumberFormatter', () {
    test('decimal groups per locale', () {
      expect(NumberFormatter.decimal(1234567.89, locale: 'en'), '1,234,567.89');
      expect(NumberFormatter.decimal(1234567.89, locale: 'ar'), contains('١'));
    });

    test('compact per locale', () {
      expect(NumberFormatter.compact(1500000, locale: 'en'), '1.5M');
    });

    test('percent per locale', () {
      expect(NumberFormatter.percent(0.42, locale: 'en'), '42%');
      expect(NumberFormatter.percent(0.42, locale: 'ar'), contains('٤٢'));
    });
  });
}
