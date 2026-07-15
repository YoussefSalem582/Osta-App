import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Global auth signals emitted by the networking layer.
///
/// The router/auth epics listen to [onSessionExpired] to force logout when a
/// 401 survives the single refresh-and-retry.
class AuthEvents {
  final _sessionExpired = StreamController<void>.broadcast();

  /// Fires when the session is irrecoverably unauthenticated.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  void emitSessionExpired() => _sessionExpired.add(null);

  /// Wired to get_it's `dispose` callback in `configureDependencies()`.
  Future<void> dispose() => _sessionExpired.close();
}

/// Sanctum dual-token pair extracted from an auth response `data` block.
typedef TokenPair = ({String accessToken, String refreshToken});

/// Parses a token pair from envelope `data`, tolerating both the Laravel
/// snake_case keys and camelCase variants.
TokenPair parseTokenPair(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Auth response has no token data');
  }
  String read(String snake, String camel) {
    final value = data[snake] ?? data[camel];
    if (value is! String) throw FormatException('Missing $snake');
    return value;
  }

  return (
    accessToken: read('access_token', 'accessToken'),
    refreshToken: read('refresh_token', 'refreshToken'),
  );
}

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

  static const _retriedKey = 'retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[ApiClient.noAuthKey] != true) {
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
        options.extra[ApiClient.noAuthKey] != true &&
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

/// Builds the shared [Dio] client every feature request flows through.
///
/// Configured against [AppConfig.baseUrl] (`/api/v1`) with Sanctum auth,
/// automatic retries, and a redacted logger. Wired up manually in
/// `configureDependencies()`.
Dio buildAppDio(AppConfig config, TokenStorage tokens, AuthEvents events) {
  final client = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  client.interceptors
    // Auth first: token attach + 401 refresh-retry-once.
    ..add(AuthInterceptor(tokens, events, config: config))
    ..add(RetryInterceptor(dio: client))
    // Headers (incl. Authorization) and bodies are never logged, but the
    // request URI is — and that carries query params, including the user's GPS
    // coordinates on /centers/nearby. Debug builds only: PrettyDioLogger prints
    // to stdout, which is readable on-device in release.
    // `enabled:` looks redundant only because kDebugMode is a const true while
    // analyzing; dropping it is what would restore release logging.
    // ignore: avoid_redundant_argument_values
    ..add(PrettyDioLogger(responseBody: false, enabled: kDebugMode));
  return client;
}

/// Exchanges a Google/Apple provider token for Sanctum dual tokens and
/// persists them. The social-login UI epics (#35/#36) call this and then read
/// the stored session — no token plumbing in screens.
class SocialTokenExchange {
  SocialTokenExchange(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  /// [provider] is the backend route segment (`google` or `apple`).
  Future<void> exchange({
    required String provider,
    required String providerToken,
  }) async {
    final result = await _api.post(
      ApiEndpoints.authSocial(provider),
      body: {'token': providerToken},
      authenticated: false,
      parse: parseTokenPair,
    );
    await _tokens.writeTokens(
      accessToken: result.data.accessToken,
      refreshToken: result.data.refreshToken,
    );
  }
}
