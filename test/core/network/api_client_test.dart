import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_client.dart';

void main() {
  group('PaginationMeta.fromJson', () {
    test('reads the real backend shape — nested under `pagination`', () {
      // osta_backend's ApiResponse::paginated() nests these under a
      // `pagination` key, not flat on `meta` — the flat-only reader threw a
      // cast error on every single paginated response until this was fixed.
      final meta = PaginationMeta.fromJson(const {
        'pagination': {
          'total': 42,
          'count': 20,
          'per_page': 20,
          'current_page': 1,
          'last_page': 3,
        },
      });

      expect(meta.total, 42);
      expect(meta.perPage, 20);
      expect(meta.currentPage, 1);
      expect(meta.lastPage, 3);
    });

    test('still reads a flat shape if the backend ever stops nesting it', () {
      final meta = PaginationMeta.fromJson(const {
        'total': 5,
        'per_page': 10,
        'current_page': 1,
        'last_page': 1,
      });

      expect(meta.total, 5);
      expect(meta.perPage, 10);
    });
  });
}
