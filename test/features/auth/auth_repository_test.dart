import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/auth/shared/data/auth_repository_impl.dart';

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
      username: 'youssef',
      email: 'y@osta.dev',
      password: 'Passw0rd',
      accountType: AppRole.business,
      phone: '01000000000',
    );

    expect(role, AppRole.business);
    final body = adapter.bodies.single! as Map<String, dynamic>;
    expect(body['account_type'], 'business');
    expect(body['username'], 'youssef');
    expect(body['password'], 'Passw0rd');
    expect(body['password_confirmation'], 'Passw0rd');
    expect(body['phone'], '01000000000');
    expect(storage.access, 'access-business');
  });

  test('isUsernameAvailable reads data.available unauthenticated', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(200, {
        'success': true,
        'data': {'available': true},
      }),
    ]);

    final free = await _repo(
      adapter,
      FakeTokenStorage(),
    ).isUsernameAvailable('free_name');

    expect(free, isTrue);
    final request = adapter.requests.single;
    expect(request.path, contains('/auth/check-username'));
    expect(request.extra['no-auth'], isTrue);
  });

  test('isUsernameAvailable is false for a taken name', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(200, {
        'success': true,
        'data': {'available': false},
      }),
    ]);

    final taken = await _repo(
      adapter,
      FakeTokenStorage(),
    ).isUsernameAvailable('taken');

    expect(taken, isFalse);
  });

  test('register omits an empty phone', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(201, _authEnvelope('customer')),
    ]);

    await _repo(adapter, FakeTokenStorage()).register(
      firstName: 'A',
      lastName: 'B',
      username: 'ab',
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

  test('logout revokes server-side and clears tokens', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(200, {'success': true, 'data': null}),
    ]);
    final storage = FakeTokenStorage()
      ..access = 'a'
      ..refresh = 'r';

    await _repo(adapter, storage).logout();

    final request = adapter.requests.single;
    expect(request.path, contains('/auth/logout'));
    expect(request.extra['no-auth'], isNull); // authenticated request
    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('logout still clears tokens when the server rejects', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(500, {
        'success': false,
        'error': {'code': 'SERVER_ERROR', 'message': 'boom'},
      }),
    ]);
    final storage = FakeTokenStorage()
      ..access = 'a'
      ..refresh = 'r';

    await _repo(adapter, storage).logout(); // does not throw

    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('forgotPassword posts the email unauthenticated', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(200, {'success': true, 'data': null}),
    ]);

    await _repo(adapter, FakeTokenStorage()).forgotPassword(email: 'a@b.com');

    final request = adapter.requests.single;
    expect(request.path, contains('/forgot-password'));
    expect(request.extra['no-auth'], isTrue);
    expect(adapter.bodies.single, {'email': 'a@b.com'});
  });

  test('resetPassword posts token + password_confirmation', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(200, {'success': true, 'data': null}),
    ]);

    await _repo(adapter, FakeTokenStorage()).resetPassword(
      email: 'a@b.com',
      token: 'tok',
      password: 'Passw0rd',
    );

    final request = adapter.requests.single;
    expect(request.path, contains('/reset-password'));
    expect(request.extra['no-auth'], isTrue);
    expect(adapter.bodies.single, {
      'email': 'a@b.com',
      'token': 'tok',
      'password': 'Passw0rd',
      'password_confirmation': 'Passw0rd',
    });
  });
}
