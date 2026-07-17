import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/shared/auth/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Both role gates ask the server, not a local flag. The business one used to
/// be a `SharedPreferences` bool that sign-out wiped, so a returning owner was
/// marched back through a wizard they had already finished — re-submitting
/// their identity and re-attaching their catalog every time.

class _FakeTokens implements TokenStorage {
  String? access = 'access-token';

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => 'refresh-token';

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
  }

  @override
  Future<void> clear() async => access = null;
}

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

Map<String, dynamic> _ok(Object? data) => {'success': true, 'data': data};

/// One service, as `GET /business/services` returns them.
const _service = {'id': 's1', 'name': 'Oil Change', 'price': '350.00'};

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late SessionStore store;

  Future<SessionController> controllerFor(AppRole role) async {
    await store.writeActiveRole(role);
    return SessionController(
      store,
      AuthEvents(),
      _FakeAuthRepo(),
      ApiClient(dio),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = SessionStore(await SharedPreferences.getInstance(), _FakeTokens());
    dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'));
    adapter = DioAdapter(dio: dio);
  });

  group('business onboarding gate', () {
    test(
      'a non-empty catalog means onboarded — the wizard stays closed',
      () async {
        final paths = <String>[];
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              paths.add(options.path);
              handler.next(options);
            },
          ),
        );
        adapter.onGet(
          ApiEndpoints.businessServices,
          (server) => server.reply(200, _ok([_service])),
        );

        final session = await controllerFor(AppRole.business);
        await session.bootstrap();

        expect(session.state.businessOnboarded, isTrue);
        // The two gates are role-exclusive, so a business launch must not pay
        // for the customer's check either.
        expect(paths, [ApiEndpoints.businessServices]);
      },
    );

    test('an empty catalog opens the wizard', () async {
      adapter.onGet(
        ApiEndpoints.businessServices,
        (server) => server.reply(200, _ok(<Object?>[])),
      );

      final session = await controllerFor(AppRole.business);
      await session.bootstrap();

      expect(session.state.businessOnboarded, isFalse);
    });

    test('a failed check resolves null, so the guard fails open', () async {
      // A 403 here means no center at all (the social-signup gap). Whatever the
      // cause, an unresolved check must not re-run a finished wizard.
      adapter.onGet(
        ApiEndpoints.businessServices,
        (server) => server.reply(403, {
          'success': false,
          'error': {'code': 'FORBIDDEN', 'message': 'no center'},
        }),
      );

      final session = await controllerFor(AppRole.business);
      await session.bootstrap();

      expect(session.state.businessOnboarded, isNull);
    });

    test(
      'survives sign-out: the catalog is server state, not a local flag',
      () async {
        adapter.onGet(
          ApiEndpoints.businessServices,
          (server) => server.reply(200, _ok([_service])),
        );

        final session = await controllerFor(AppRole.business);
        await session.signOut();
        // Signing back in re-derives from the catalog the owner still owns.
        await session.chooseRole(AppRole.business);
        await session.onAuthenticated(
          AppRole.business,
          requested: AppRole.business,
        );

        expect(session.state.businessOnboarded, isTrue);
      },
    );

    test('never fires for a customer, and costs them no request', () async {
      // Asserting `businessOnboarded == null` alone would prove nothing: the
      // gate swallows every failure to null, so a stray request that 404'd
      // would look identical. Watch the wire instead.
      final paths = <String>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add(options.path);
            handler.next(options);
          },
        ),
      );
      adapter.onGet(
        ApiEndpoints.vehicles,
        (server) => server.reply(200, _ok(<Object?>[])),
      );

      final session = await controllerFor(AppRole.customer);
      await session.bootstrap();

      expect(session.state.businessOnboarded, isNull);
      expect(session.state.hasVehicle, isFalse);
      expect(paths, [ApiEndpoints.vehicles]);
      expect(paths, isNot(contains(ApiEndpoints.businessServices)));
    });
  });

  group('customer add-car gate', () {
    test(
      'an owned car releases the gate; the business one stays null',
      () async {
        adapter.onGet(
          ApiEndpoints.vehicles,
          (server) => server.reply(
            200,
            _ok([
              {'id': 'v1', 'make': 'Toyota', 'model': 'Corolla'},
            ]),
          ),
        );

        final session = await controllerFor(AppRole.customer);
        await session.bootstrap();

        expect(session.state.hasVehicle, isTrue);
        expect(session.state.businessOnboarded, isNull);
      },
    );
  });
}
