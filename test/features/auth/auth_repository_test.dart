import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/auth/data/auth_repository_impl.dart';

import '../../core/network/fakes.dart';

Map<String, dynamic> _authEnvelope(String type) => {
  'success': true,
  'data': {
    'user': {'id': 'u1', 'type': type},
    'access_token': 'access-$type',
    'refresh_token': 'refresh-$type',
    'token_type': 'Bearer',
    'expires_at': '2030-01-01T00:00:00Z',
    'new_user': false,
  },
};

AuthRepositoryImpl _repo(ScriptedAdapter adapter, FakeTokenStorage storage) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
    ..httpClientAdapter = adapter;
  return AuthRepositoryImpl(ApiClient(dio), storage);
}

void main() {
  test(
    'login sends account_type, returns me.type, and persists tokens',
    () async {
      final adapter = ScriptedAdapter([
        (_) => jsonResponse(200, _authEnvelope('customer')),
      ]);
      final storage = FakeTokenStorage();

      final role = await _repo(adapter, storage).login(
        email: 'a@b.com',
        password: 'secret12',
        accountType: AppRole.customer,
      );

      expect(role, AppRole.customer);
      final request = adapter.requests.single;
      expect(request.path, contains('/auth/login'));
      expect(request.extra['no-auth'], isTrue); // login is unauthenticated
      expect(adapter.bodies.single, {
        'email': 'a@b.com',
        'password': 'secret12',
        'account_type': 'customer',
      });
      expect(storage.access, 'access-customer');
      expect(storage.refresh, 'refresh-customer');
    },
  );

  test('register sends account_type + password_confirmation', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(201, _authEnvelope('business')),
    ]);
    final storage = FakeTokenStorage();

    final role = await _repo(adapter, storage).register(
      firstName: 'Youssef',
      lastName: 'Salem',
      email: 'y@osta.dev',
      password: 'Passw0rd',
      accountType: AppRole.business,
      phone: '01000000000',
    );

    expect(role, AppRole.business);
    final body = adapter.bodies.single! as Map<String, dynamic>;
    expect(body['account_type'], 'business');
    expect(body['password'], 'Passw0rd');
    expect(body['password_confirmation'], 'Passw0rd');
    expect(body['phone'], '01000000000');
    expect(storage.access, 'access-business');
  });

  test('register omits an empty phone', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(201, _authEnvelope('customer')),
    ]);

    await _repo(adapter, FakeTokenStorage()).register(
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.com',
      password: 'Passw0rd',
      accountType: AppRole.customer,
      phone: '',
    );

    expect((adapter.bodies.single! as Map).containsKey('phone'), isFalse);
  });

  test(
    'the returned role is the server me.type, healing a wrong request',
    () async {
      // We ask for customer, but the account is a business one.
      final adapter = ScriptedAdapter([
        (_) => jsonResponse(200, _authEnvelope('business')),
      ]);

      final role = await _repo(
        adapter,
        FakeTokenStorage(),
      ).login(email: 'a@b.com', password: 'x', accountType: AppRole.customer);

      expect(role, AppRole.business);
    },
  );
}
