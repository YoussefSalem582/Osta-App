import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';

/// The Product parser is the app↔backend contract boundary: if `ProductResource`
/// (osta_backend) and this mapping disagree, every shop screen breaks. These
/// assert the exact shape the backend Shop tests emit.
void main() {
  group('Product.fromJson', () {
    test('maps a full ServiceCenter-owned product', () {
      final product = Product.fromJson({
        'id': 'prod-1',
        'name': 'Premium Brake Pads',
        'description': 'OEM quality',
        'category': 'brakes',
        'price': 1250.5,
        'images': ['https://cdn/a.jpg', 'https://cdn/b.jpg'],
        'status': 'active',
        'owner': {
          'type': 'service_center',
          'id': 'center-9',
          'name': 'Cairo Auto',
        },
        'created_at': '2026-07-17T00:00:00+00:00',
      });

      expect(product.id, 'prod-1');
      expect(product.name, 'Premium Brake Pads');
      expect(product.price, 1250.5);
      expect(product.images, hasLength(2));
      expect(product.isActive, isTrue);
      expect(product.owner?.name, 'Cairo Auto');
      expect(product.owner?.isCenter, isTrue);
    });

    test('coerces an integer price and a user owner slug', () {
      final product = Product.fromJson({
        'id': 'prod-2',
        'name': 'Used Battery',
        'price': 900, // backend can serialise a whole number as int
        'status': 'inactive',
        'owner': {'type': 'user', 'id': 'user-3', 'name': 'Sara'},
      });

      expect(product.price, 900.0);
      expect(product.isActive, isFalse);
      expect(product.owner?.isCenter, isFalse);
    });

    test('tolerates missing optionals — no images, no owner', () {
      final product = Product.fromJson({
        'id': 'prod-3',
        'name': 'Mystery Part',
        'price': '49.99', // and a string price
      });

      expect(product.images, isEmpty);
      expect(product.owner, isNull);
      expect(product.description, isNull);
      expect(product.price, 49.99);
      expect(product.status, 'active'); // default
    });
  });
}
