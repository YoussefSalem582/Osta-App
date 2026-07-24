import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository_impl.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/customer/garage/data/garage_repository_impl.dart';
import 'package:osta/features/shared/auth/data/auth_repository_impl.dart';

/// Every bug these cover shipped green: each one sent a wrong path, verb, key
/// or header while the server answered 2xx (or the client swallowed the 401).
/// Unit tests over cubits cannot see any of it, so these assert the bytes.

class _FakeTokens implements TokenStorage {
  String? access = 'access-token';
  String? refresh = 'refresh-token';

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Envelope shape from `ApiResponse::success`.
Map<String, dynamic> _ok(Object? data) => {'success': true, 'data': data};

void main() {
  group('password recovery paths', () {
    // These were /forgot-password and /reset-password, which the backend has
    // never registered — the whole feature 404'd.
    test('are nested under the auth prefix', () {
      expect(ApiEndpoints.authPasswordForgot, '/auth/password/forgot');
      expect(ApiEndpoints.authPasswordReset, '/auth/password/reset');
    });
  });

  group('token refresh', () {
    test('presents the refresh token as Bearer, with no body', () async {
      // /auth/refresh sits behind auth:sanctum + ability:refresh and reads
      // $request->user(). The refresh token IS the credential (a PAT minted
      // with the 'refresh' ability). Posting it as {refresh_token: ...} with no
      // Authorization header 401s, and the catch for a failed refresh clears
      // the session — so every user was logged out the moment their access
      // token expired.
      final tokens = _FakeTokens();
      final events = AuthEvents();
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));

      // Bare, exactly as production builds it: the interceptor replays through
      // this client, so routing it back through itself would loop forever.
      final refreshDio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
      final refreshAdapter = DioAdapter(dio: refreshDio);

      String? sentAuth;
      Object? sentBody;
      refreshDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.authRefresh) {
              sentAuth = options.headers['Authorization'] as String?;
              sentBody = options.data;
            }
            handler.next(options);
          },
        ),
      );
      refreshAdapter
        ..onPost(
          ApiEndpoints.authRefresh,
          (server) => server.reply(
            200,
            _ok({'access_token': 'new-access', 'refresh_token': 'new-refresh'}),
          ),
        )
        // The replayed original request, once the token has rotated.
        ..onGet('/me', (server) => server.reply(200, _ok({'id': '1'})));

      DioAdapter(dio: dio).onGet(
        '/me',
        (server) => server.reply(401, {
          'success': false,
          'error': {'code': 'UNAUTHENTICATED', 'message': 'nope'},
        }),
      );
      dio.interceptors.add(
        AuthInterceptor(
          tokens,
          events,
          config: AppConfig(),
          refreshDio: refreshDio,
        ),
      );

      await dio.get<dynamic>('/me');

      expect(sentAuth, 'Bearer refresh-token');
      expect(
        sentBody,
        isNot(
          isA<Map<String, dynamic>>().having(
            (m) => m.containsKey('refresh_token'),
            'refresh_token in body',
            isTrue,
          ),
        ),
      );
      // Rotation still lands, and the session survives.
      expect(tokens.access, 'new-access');
      expect(tokens.refresh, 'new-refresh');
      await events.dispose();
    });
  });

  group('Accept-Language', () {
    test('is sent from the session locale', () async {
      // SetApiLocale resolves the request locale from this header and defaults
      // to Arabic, so without it an English user gets Arabic 422 messages.
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
      final adapter = DioAdapter(dio: dio);
      dio.interceptors.add(LocaleInterceptor(() => 'en'));
      String? sent;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent = options.headers['Accept-Language'] as String?;
            handler.next(options);
          },
        ),
      );
      adapter.onGet('/me', (server) => server.reply(200, _ok({})));

      await dio.get<dynamic>('/me');
      expect(sent, 'en');
    });

    test(
      'is omitted on a true first run so the server default applies',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
        final adapter = DioAdapter(dio: dio);
        dio.interceptors.add(LocaleInterceptor(() => null));
        var hasHeader = true;
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              hasHeader = options.headers.containsKey('Accept-Language');
              handler.next(options);
            },
          ),
        );
        adapter.onGet('/me', (server) => server.reply(200, _ok({})));

        await dio.get<dynamic>('/me');
        expect(hasHeader, isFalse);
      },
    );
  });

  group('POST /vehicles body', () {
    late Dio dio;
    late DioAdapter adapter;

    setUp(() async {
      dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
      adapter = DioAdapter(dio: dio);
      await GetIt.instance.reset();
      GetIt.instance.registerSingleton<ApiClient>(ApiClient(dio));
    });

    tearDown(() async => GetIt.instance.reset());

    test('uses the keys StoreVehicleRequest actually validates', () async {
      // 'plate' is not a rule key, and every optional rule is nullable — so the
      // misspelling was not a 422, it was a silent drop that still returned
      // 201. The plate vanished on every save.
      Object? sent;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent = options.data;
            handler.next(options);
          },
        ),
      );
      adapter.onPost(
        ApiEndpoints.vehicles,
        (server) => server.reply(201, _ok({})),
        data: Matchers.any,
      );

      await GarageRepositoryImpl(ApiClient(dio)).addVehicle(
        make: 'Toyota',
        model: 'Corolla',
        year: 2020,
        plateNumber: 'A B 1 2 3',
        currentMileage: 45000,
      );

      final body = sent! as Map<String, dynamic>;
      expect(body['plate_number'], 'A B 1 2 3');
      expect(body['current_mileage'], 45000);
      expect(body.containsKey('plate'), isFalse);
      expect(body.containsKey('kilometers'), isFalse);
    });
  });

  group('PUT /business/profile transport', () {
    late Dio dio;
    late DioAdapter adapter;
    late BusinessOnboardingRepositoryImpl repo;
    RequestOptions? sent;

    setUp(() {
      sent = null;
      dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
      adapter = DioAdapter(dio: dio);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent = options;
            handler.next(options);
          },
        ),
      );
      repo = BusinessOnboardingRepositoryImpl(ApiClient(dio));
    });

    test('a logo forces POST with _method=PUT, not a real PUT', () async {
      // PHP only parses multipart/form-data on POST. A real PUT leaves $_POST
      // and $_FILES empty, and since every rule on UpdateBusinessProfileRequest
      // is `sometimes`, that validates clean and saves nothing — 200 OK with
      // the entire profile discarded. The backend's own test cannot catch this:
      // $this->put(['logo' => UploadedFile::fake()]) injects into Symfony's
      // file bag and never builds a multipart body.
      final logo = File(
        '${Directory.systemTemp.path}/osta_wire_logo.png',
      )..writeAsBytesSync([1, 2, 3]);
      addTearDown(logo.deleteSync);

      adapter.onPost(
        ApiEndpoints.businessProfile,
        (server) => server.reply(200, _ok({})),
        data: Matchers.any,
      );

      await repo.updateProfile(
        BusinessProfileInput(tradeName: 'Cairo Motors', logoPath: logo.path),
      );

      expect(sent!.method, 'POST');
      final body = sent!.data! as FormData;
      final fields = {for (final f in body.fields) f.key: f.value};
      expect(fields['_method'], 'PUT');
      expect(fields['trade_name'], 'Cairo Motors');
      expect(body.files.map((f) => f.key), contains('logo'));
    });

    test('without a logo it stays a JSON PUT', () async {
      // Laravel parses JSON on any verb, so this path was always fine.
      adapter.onPut(
        ApiEndpoints.businessProfile,
        (server) => server.reply(200, _ok({})),
        data: Matchers.any,
      );

      await repo.updateProfile(const BusinessProfileInput(tradeName: 'Cairo'));

      expect(sent!.method, 'PUT');
      expect(sent!.data, isA<Map<String, dynamic>>());
    });
  });

  group('POST /auth/register body', () {
    test('sends language_preference and the account type', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
      final adapter = DioAdapter(dio: dio);
      Object? sent;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent = options.data;
            handler.next(options);
          },
        ),
      );
      adapter.onPost(
        ApiEndpoints.authRegister,
        (server) => server.reply(
          201,
          _ok({
            'user': {'type': 'business'},
            'access_token': 'a',
            'refresh_token': 'r',
          }),
        ),
        data: Matchers.any,
      );

      final role =
          await AuthRepositoryImpl(
            ApiClient(dio),
            _FakeTokens(),
          ).register(
            firstName: 'Sara',
            lastName: 'Ahmed',
            username: 'sara',
            email: 'sara@example.com',
            password: 'Password1',
            accountType: AppRole.business,
            languagePreference: 'en',
          );

      final body = sent! as Map<String, dynamic>;
      expect(body['language_preference'], 'en');
      expect(body['account_type'], 'business');
      // The role comes from the server's user.type, never the request.
      expect(role, AppRole.business);
    });
  });
}
