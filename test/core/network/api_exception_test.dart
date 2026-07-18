import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';

void main() {
  group('apiExceptionFromEnvelope', () {
    test('maps METHOD_NOT_ALLOWED to MethodNotAllowedException', () {
      final e = apiExceptionFromEnvelope({
        'code': 'METHOD_NOT_ALLOWED',
        'message': 'The GET method is not supported for route …',
      });
      // The business profile/address screens rely on this exact type to fall
      // back to a blank form when GET /business/profile isn't deployed.
      expect(e, isA<MethodNotAllowedException>());
    });

    test('unknown codes still fall back to ServerException', () {
      final e = apiExceptionFromEnvelope({'code': 'WAT', 'message': 'x'});
      expect(e, isA<ServerException>());
    });
  });
}
