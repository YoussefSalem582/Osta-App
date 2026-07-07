import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/session/app_role.dart';

void main() {
  group('AppRole', () {
    test('wireName mirrors the backend account_type / me.type value', () {
      expect(AppRole.customer.wireName, 'customer');
      expect(AppRole.business.wireName, 'business');
      expect(AppRole.mechanic.wireName, 'mechanic');
      expect(AppRole.tow.wireName, 'tow');
    });

    test('only customer and business are available', () {
      expect(AppRole.customer.isAvailable, isTrue);
      expect(AppRole.business.isAvailable, isTrue);
      expect(AppRole.mechanic.isAvailable, isFalse);
      expect(AppRole.tow.isAvailable, isFalse);
    });

    test('fromWire round-trips known roles', () {
      for (final role in AppRole.values) {
        expect(AppRole.fromWire(role.wireName), role);
      }
    });

    test('fromWire returns null for unmapped/absent types', () {
      expect(AppRole.fromWire('admin'), isNull);
      expect(AppRole.fromWire(null), isNull);
      expect(AppRole.fromWire(''), isNull);
    });
  });
}
