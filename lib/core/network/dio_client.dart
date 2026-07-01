import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:injectable/injectable.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Provides the shared [Dio] client for the app.
///
/// Configured against [AppConfig.baseUrl] with automatic retries and a
/// redacted logger. No live endpoints are wired here yet.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AppConfig config) {
    final client = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    client.interceptors
      ..add(RetryInterceptor(dio: client))
      // Redacted: response bodies are never logged (defaults keep headers and
      // request bodies off too).
      ..add(PrettyDioLogger(responseBody: false));
    return client;
  }
}
