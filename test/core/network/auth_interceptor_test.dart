import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/dio_client.dart';

import 'fakes.dart';

void main() {
  const base = 'https://api.test/api/v1';

  late FakeTokenStorage storage;
  late AuthEvents events;
  late List<void> expiredEvents;

  setUp(() {
    storage = FakeTokenStorage()
      ..access = 'old-access'
      ..refresh = 'old-refresh';
    events = AuthEvents();
    expiredEvents = [];
    events.onSessionExpired.listen(expiredEvents.add);
  });

  tearDown(() => events.dispose());

  Dio buildDio(ScriptedAdapter adapter) {
    final refreshDio = Dio(BaseOptions(baseUrl: base))
      ..httpClientAdapter = adapter;
    return Dio(BaseOptions(baseUrl: base))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          storage,
          events,
          config: AppConfig(),
          refreshDio: refreshDio,
        ),
      );
  }

  test('attaches stored access token as Bearer', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(200, {'success': true, 'data': null}),
    ]);

    await buildDio(adapter).get<dynamic>('/me');

    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer old-access',
    );
  });

  test('401 → exactly one refresh, token rotation, single replay', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'expired'},
      }),
      (_) => jsonResponse(200, tokenEnvelope('new-access', 'new-refresh')),
      (_) => jsonResponse(200, {'success': true, 'data': 'hello'}),
    ]);

    final response = await buildDio(adapter).get<dynamic>('/me');

    expect(response.statusCode, 200);
    expect(adapter.requests, hasLength(3));
    expect(adapter.requests[1].path, contains('/auth/refresh'));
    expect(adapter.bodies[1], {'refresh_token': 'old-refresh'});
    expect(adapter.requests[2].headers['Authorization'], 'Bearer new-access');
    // Tokens rotated in secure storage.
    expect(storage.access, 'new-access');
    expect(storage.refresh, 'new-refresh');
    // Session never flagged as expired.
    await pumpEventQueue();
    expect(expiredEvents, isEmpty);
  });

  test('failed refresh → tokens cleared + session-expired emitted', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'expired'},
      }),
      (_) => jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'bad refresh'},
      }),
    ]);

    await expectLater(
      buildDio(adapter).get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(2)); // original + refresh only
    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
    await pumpEventQueue();
    expect(expiredEvents, hasLength(1));
  });

  test('second 401 after refresh → no second refresh, logout', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'expired'},
      }),
      (_) => jsonResponse(200, tokenEnvelope('new-access', 'new-refresh')),
      (_) => jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'still expired'},
      }),
    ]);

    await expectLater(
      buildDio(adapter).get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );

    // original + one refresh + one replay — never a second refresh.
    expect(adapter.requests, hasLength(3));
    expect(storage.access, isNull);
    await pumpEventQueue();
    expect(expiredEvents, hasLength(1));
  });

  test('no-auth requests skip token attachment and refresh', () async {
    final adapter = ScriptedAdapter([
      (_) => jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'nope'},
      }),
    ]);

    await expectLater(
      buildDio(adapter).get<dynamic>(
        '/auth/login',
        options: Options(extra: const {ApiClient.noAuthKey: true}),
      ),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests.single.headers['Authorization'], isNull);
    expect(adapter.requests, hasLength(1)); // no refresh attempt
    expect(storage.access, 'old-access'); // untouched
  });
}
