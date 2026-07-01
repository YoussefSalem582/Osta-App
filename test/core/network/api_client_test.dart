import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart' hide Matcher;
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_exception.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ApiClient api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'));
    adapter = DioAdapter(dio: dio);
    api = ApiClient(dio);
  });

  test('parses success envelope into typed data + pagination meta', () async {
    adapter.onGet(
      '/items',
      (server) => server.reply(200, {
        'success': true,
        'data': [1, 2, 3],
        'meta': {
          'current_page': 2,
          'last_page': 5,
          'per_page': 10,
          'total': 42,
        },
      }),
    );

    final result = await api.get(
      '/items',
      parse: (data) => (data! as List).cast<int>(),
    );

    expect(result.data, [1, 2, 3]);
    expect(result.meta?.currentPage, 2);
    expect(result.meta?.lastPage, 5);
    expect(result.meta?.perPage, 10);
    expect(result.meta?.total, 42);
  });

  test('success envelope without meta leaves meta null', () async {
    adapter.onGet(
      '/one',
      (server) => server.reply(200, {'success': true, 'data': 'ok'}),
    );

    final result = await api.get('/one', parse: (data) => data! as String);

    expect(result.data, 'ok');
    expect(result.meta, isNull);
  });

  group('maps every error code to its typed exception', () {
    const cases = <(String, int, Matcher)>[
      ('VALIDATION_ERROR', 422, TypeMatcher<ValidationException>()),
      ('UNAUTHENTICATED', 401, TypeMatcher<UnauthenticatedException>()),
      ('FORBIDDEN', 403, TypeMatcher<ForbiddenException>()),
      ('NOT_FOUND', 404, TypeMatcher<NotFoundException>()),
      ('TOO_MANY_REQUESTS', 429, TypeMatcher<RateLimitException>()),
      ('SERVER_ERROR', 500, TypeMatcher<ServerException>()),
      ('SOMETHING_NEW', 500, TypeMatcher<ServerException>()), // unknown code
    ];

    for (final (code, status, matcher) in cases) {
      test('$code ($status)', () async {
        adapter.onGet(
          '/fail',
          (server) => server.reply(status, {
            'success': false,
            'error': {'code': code, 'message': 'boom'},
          }),
        );

        await expectLater(
          api.get('/fail', parse: (data) => data),
          throwsA(matcher),
        );
      });
    }
  });

  test('VALIDATION_ERROR exposes per-field details', () async {
    adapter.onPost(
      '/register',
      (server) => server.reply(422, {
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Invalid input',
          'details': {
            'email': ['Already taken'],
            'phone': 'Invalid format',
          },
        },
      }),
      data: Matchers.any,
    );

    await expectLater(
      api.post('/register', body: const {}, parse: (data) => data),
      throwsA(
        isA<ValidationException>()
            .having((e) => e.fieldErrors['email'], 'email', ['Already taken'])
            .having((e) => e.fieldErrors['phone'], 'phone', ['Invalid format']),
      ),
    );
  });

  test('transport failure maps to NetworkException', () async {
    adapter.onGet(
      '/offline',
      (server) => server.throws(
        0,
        DioException.connectionTimeout(
          timeout: const Duration(seconds: 1),
          requestOptions: RequestOptions(path: '/offline'),
        ),
      ),
    );

    await expectLater(
      api.get('/offline', parse: (data) => data),
      throwsA(isA<NetworkException>()),
    );
  });
}
