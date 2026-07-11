import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/dio_client.dart';

import 'fakes.dart';

void main() {
  test('posts provider token and persists the Sanctum pair', () async {
    final adapter = ScriptedAdapter([
      (_) =>
          jsonResponse(200, tokenEnvelope('sanctum-access', 'sanctum-refresh')),
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    final storage = FakeTokenStorage();
    final exchange = SocialTokenExchange(ApiClient(dio), storage);

    await exchange.exchange(provider: 'google', providerToken: 'g-token');

    final request = adapter.requests.single;
    expect(request.path, contains('/auth/social/google'));
    expect(adapter.bodies.single, {'token': 'g-token'});
    // Unauthenticated call — interceptors must skip the Bearer header.
    expect(request.extra['no-auth'], isTrue);
    expect(storage.access, 'sanctum-access');
    expect(storage.refresh, 'sanctum-refresh');
  });
}
