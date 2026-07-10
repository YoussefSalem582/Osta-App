import 'package:dio/dio.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/auth_events.dart';
import 'package:osta/core/network/token_pair.dart';

/// Attaches the Sanctum access token and transparently handles expiry:
/// on a 401 the refresh endpoint is called once, tokens are rotated, and the
/// original request is replayed a single time. A second 401 (or a failed
/// refresh) clears tokens and emits a global session-expired event.
///
/// [QueuedInterceptor] serializes callbacks so concurrent 401s cannot run
/// overlapping refreshes.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(
    this._tokens,
    this._events, {
    required AppConfig config,
    Dio? refreshDio,
  }) : // Bare client (no interceptors) so refresh/replay can never loop back
       // through this interceptor.
       _refreshDio = refreshDio ?? Dio(BaseOptions(baseUrl: config.baseUrl));

  final TokenStorage _tokens;
  final AuthEvents _events;
  final Dio _refreshDio;

  /// Set `extra: {noAuthKey: true}` on a request to skip token attachment
  /// (e.g. login / social exchange).
  static const noAuthKey = 'no-auth';
  static const _retriedKey = 'retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[noAuthKey] != true) {
      final access = await _tokens.readAccessToken();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final eligible =
        err.response?.statusCode == 401 &&
        options.extra[noAuthKey] != true &&
        options.extra[_retriedKey] != true;
    if (!eligible) return handler.next(err);

    try {
      final access = await _freshAccessToken(options);
      options.extra[_retriedKey] = true;
      options.headers['Authorization'] = 'Bearer $access';
      final response = await _refreshDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on Exception {
      await _tokens.clear();
      _events.emitSessionExpired();
      handler.next(err);
    }
  }

  /// Returns a valid access token, refreshing at most once.
  ///
  /// If another queued request already rotated the tokens while this one was
  /// in flight, reuse the stored token instead of re-consuming the (rotated,
  /// single-use) refresh token — a second refresh would fail and force a
  /// spurious logout.
  Future<String> _freshAccessToken(RequestOptions failed) async {
    final stored = await _tokens.readAccessToken();
    final sentHeader = failed.headers['Authorization'];
    if (stored != null && sentHeader != 'Bearer $stored') return stored;

    final refresh = await _tokens.readRefreshToken();
    if (refresh == null) throw const FormatException('No refresh token');
    final response = await _refreshDio.post<Map<String, dynamic>>(
      ApiEndpoints.authRefresh,
      data: {'refresh_token': refresh},
    );
    final pair = parseTokenPair(response.data?['data']);
    await _tokens.writeTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );
    return pair.accessToken;
  }
}
