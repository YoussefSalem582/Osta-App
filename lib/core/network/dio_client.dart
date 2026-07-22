import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Global auth signals; [onSessionExpired] forces logout when a 401 survives
/// the single refresh-and-retry.
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

/// Sets the `Accept-Language` header per request (not baked into
/// `BaseOptions`) since the language screen can change locale after the
/// client is built.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._localeCode);

  /// Current `ar`/`en`, or null on a true first run (backend default applies).
  final String? Function() _localeCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final code = _localeCode();
    if (code != null) options.headers['Accept-Language'] = code;
    handler.next(options);
  }
}

/// Attaches the Sanctum access token; on a 401 refreshes once and replays the
/// request, or clears tokens and emits session-expired. [QueuedInterceptor]
/// prevents concurrent refreshes.
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

  /// Returns a valid access token, refreshing at most once — reuses the
  /// stored token if another queued request already rotated it, since the
  /// refresh token is single-use.
  Future<String> _freshAccessToken(RequestOptions failed) async {
    final stored = await _tokens.readAccessToken();
    final sentHeader = failed.headers['Authorization'];
    if (stored != null && sentHeader != 'Bearer $stored') return stored;

    final refresh = await _tokens.readRefreshToken();
    if (refresh == null) throw const FormatException('No refresh token');
    // Sent as a Bearer header, not a JSON body — `/auth/refresh` reads
    // `$request->user()`, so a body field 401s here.
    final response = await _refreshDio.post<Map<String, dynamic>>(
      ApiEndpoints.authRefresh,
      options: Options(headers: {'Authorization': 'Bearer $refresh'}),
    );
    final pair = parseTokenPair(response.data?['data']);
    await _tokens.writeTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );
    return pair.accessToken;
  }
}

/// Builds the shared [Dio] client every feature request flows through:
/// base URL, Sanctum auth, retries, and a redacted logger.
Dio buildAppDio(
  AppConfig config,
  TokenStorage tokens,
  AuthEvents events, {
  required String? Function() localeCode,
}) {
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
    ..add(LocaleInterceptor(localeCode))
    ..add(RetryInterceptor(dio: client))
    // Logs the request URI (incl. GPS query params) in debug builds only;
    // `enabled:` looks redundant but is what gates it off in release.
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
