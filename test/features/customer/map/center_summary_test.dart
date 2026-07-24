import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/customer/map/data/models/center_summary.dart';

void main() {
  group('CenterSummary.fromJson', () {
    test('maps the documented snake_case payload', () {
      final center = CenterSummary.fromJson(const {
        'id': 7,
        'name': 'Nasr Center',
        'lat': 30.05,
        'lng': 31.33,
        'rating': 4.8,
        'distance_meters': 1200,
        'open_now': true,
        'price': 250,
        'category': 'oil',
        'image_url': 'https://example.test/a.png',
      });

      // id arrives as an int but the marker key is a String.
      expect(center.id, '7');
      expect(center.name, 'Nasr Center');
      expect(center.latitude, 30.05);
      expect(center.longitude, 31.33);
      expect(center.rating, 4.8);
      expect(center.distanceMeters, 1200);
      expect(center.distanceKm, 1.2);
      expect(center.isOpenNow, isTrue);
      expect(center.price, 250);
      expect(center.category, 'oil');
      expect(center.imageUrl, 'https://example.test/a.png');
      expect(center.hasPosition, isTrue);
    });

    test('accepts the alternate key spellings the contract may use', () {
      final center = CenterSummary.fromJson(const {
        'id': 'c-1',
        'title': 'Alt Keys',
        'latitude': 30.1,
        'longitude': 31.4,
        'average_rating': 4.2,
        'distance': 800,
        'is_open': false,
        'starting_price': 99,
        'type': 'tire_shop',
        'logo': 'https://example.test/b.png',
      });

      expect(center.name, 'Alt Keys');
      expect(center.latitude, 30.1);
      expect(center.longitude, 31.4);
      expect(center.rating, 4.2);
      expect(center.distanceMeters, 800);
      expect(center.isOpenNow, isFalse);
      expect(center.price, 99);
      expect(center.category, 'tire_shop');
      expect(center.imageUrl, 'https://example.test/b.png');
    });

    test('coerces the string/int encodings Laravel emits for decimals '
        'and booleans', () {
      final center = CenterSummary.fromJson(const {
        'id': 1,
        'name': 'Coerced',
        'lat': '30.06',
        'lng': '31.34',
        'rating': '4.50',
        'distance_meters': '1500.5',
        'open_now': 1,
      });

      expect(center.latitude, 30.06);
      expect(center.longitude, 31.34);
      expect(center.rating, 4.5);
      expect(center.distanceMeters, 1500.5);
      expect(center.isOpenNow, isTrue);
    });

    test('survives a payload with everything optional missing', () {
      final center = CenterSummary.fromJson(const {'id': 3});

      expect(center.id, '3');
      expect(center.name, '');
      expect(center.latitude, isNull);
      expect(center.rating, isNull);
      expect(center.distanceKm, isNull);
      expect(center.isOpenNow, isNull);
      // No coordinates => never becomes a marker.
      expect(center.hasPosition, isFalse);
    });

    test('is value-equal so identical loads do not churn map state', () {
      const json = {'id': 1, 'name': 'Same', 'lat': 30.0, 'lng': 31.0};

      expect(CenterSummary.fromJson(json), CenterSummary.fromJson(json));
    });
  });
}
