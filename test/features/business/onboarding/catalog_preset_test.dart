import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';

void main() {
  group('CatalogPreset.fromJson', () {
    test('parses the backend preset shape', () {
      final preset = CatalogPreset.fromJson(const {
        'id': '1f2e-abcd',
        'category': 'oil',
        'category_label': 'Oil & Filters',
        'name': 'Basic Oil Change',
        'default_price': 350.0,
        'default_duration_minutes': 30,
      });

      expect(preset.id, '1f2e-abcd');
      expect(preset.category, 'oil');
      expect(preset.categoryLabel, 'Oil & Filters');
      expect(preset.name, 'Basic Oil Change');
      expect(preset.defaultPrice, 350);
      expect(preset.defaultDurationMinutes, 30);
    });

    test('tolerates string-encoded numbers from Laravel', () {
      final preset = CatalogPreset.fromJson(const {
        'id': 42,
        'category': 'brakes',
        'name': 'Pads',
        'default_price': '250.50',
        'default_duration_minutes': '90',
      });

      expect(preset.id, '42');
      expect(preset.defaultPrice, 250.5);
      expect(preset.defaultDurationMinutes, 90);
    });

    test('defaults missing optional fields safely', () {
      final preset = CatalogPreset.fromJson(const {});
      expect(preset.id, '');
      expect(preset.category, '');
      expect(preset.name, '');
      expect(preset.defaultPrice, 0);
      expect(preset.defaultDurationMinutes, 0);
      expect(preset.categoryLabel, isNull);
    });
  });
}
