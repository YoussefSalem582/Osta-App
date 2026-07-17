import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:osta/core/config/app_config.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/dio_client.dart' show AuthInterceptor, AuthEvents;
import 'package:get_it/get_it.dart';
import 'package:osta/core/auth/token_storage.dart';

class DioProvider {
  static late Dio dio;
  static void init(
    AppConfig config, {
    TokenStorage? tokens,
    AuthEvents? events,
  }) {
    final client = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    try {
      final gi = GetIt.instance;
      tokens ??= gi.isRegistered<TokenStorage>() ? gi<TokenStorage>() : null;
      events ??= gi.isRegistered<AuthEvents>() ? gi<AuthEvents>() : null;
    } catch (_) {}

    if (tokens != null && events != null) {
      client.interceptors.add(AuthInterceptor(tokens, events, config: config));
    }

    client.interceptors
      ..add(RetryInterceptor(dio: client))
      ..add(PrettyDioLogger(responseBody: false));

    dio = client;
  }

  static Options? _options({Map<String, dynamic>? headers, bool authenticated = true}) {
    if (!authenticated) return Options(extra: const {ApiClient.noAuthKey: true}, headers: headers);
    return headers == null ? null : Options(headers: headers);
  }

  static Future<Response<dynamic>> post({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
  }) async {
    return dio.post<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: _options(headers: headers, authenticated: authenticated),
    );
  }

  static Future<Response<dynamic>> get({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
  }) async {
    return dio.get<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: _options(headers: headers, authenticated: authenticated),
    );
  }

  static Future<Response<dynamic>> patch({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
  }) async {
    return dio.patch<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: _options(headers: headers, authenticated: authenticated),
    );
  }

  static Future<Response<dynamic>> put({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
  }) async {
    return dio.put<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: _options(headers: headers, authenticated: authenticated),
    );
  }

  static Future<Response<dynamic>> delete({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
  }) async {
    return dio.delete<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: _options(headers: headers, authenticated: authenticated),
    );
  }
}
