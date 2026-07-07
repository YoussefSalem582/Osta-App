import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/auth_events.dart';
import 'package:osta/core/network/auth_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
    // Redacted: headers (incl. Authorization) and bodies are never logged.
    ..add(PrettyDioLogger(responseBody: false));
  return client;
}
