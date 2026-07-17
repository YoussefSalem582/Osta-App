import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:osta/core/network/api_exception.dart';

/// Pagination block from the `meta` field of list responses.
///
/// Plain immutable model with hand-written JSON mapping — no codegen. Reused by
/// every list feature (bookings, shop, notifications, …).
class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    // The backend nests these under `meta.pagination` (`ApiResponse::paginated`
    // in osta_backend), not flat on `meta` — this was written against the
    // wrong shape and threw a cast error on every single paginated response.
    final page = json['pagination'] as Map<String, dynamic>? ?? json;
    return PaginationMeta(
      currentPage: page['current_page'] as int,
      lastPage: page['last_page'] as int,
      perPage: page['per_page'] as int,
      total: page['total'] as int,
    );
  }

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}

/// Parsed success envelope: typed [data] plus optional pagination [meta].
class ApiResult<T> {
  const ApiResult(this.data, {this.meta});

  final T data;
  final PaginationMeta? meta;
}

/// Envelope-aware HTTP client — the single entry point features use.
///
/// Every call hits the env-configured `/api/v1` base (see `buildAppDio`),
/// parses the backend `ApiResponse` envelope into a typed [ApiResult], and
/// throws a typed [ApiException] on failure so screens never touch raw JSON.
class ApiClient {
  ApiClient(this._dio);

  /// Set `extra: {noAuthKey: true}` on a request to skip token attachment
  /// (e.g. login / social exchange). Read by `AuthInterceptor`.
  static const noAuthKey = 'no-auth';

  final Dio _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    required T Function(Object? data) parse,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) => _send(
    () => _dio.get<dynamic>(
      path,
      queryParameters: query,
      options: _options(authenticated),
    ),
    parse,
  );

  Future<ApiResult<T>> post<T>(
    String path, {
    required T Function(Object? data) parse,
    Object? body,
    bool authenticated = true,
  }) => _send(
    () =>
        _dio.post<dynamic>(path, data: body, options: _options(authenticated)),
    parse,
  );

  Future<ApiResult<T>> put<T>(
    String path, {
    required T Function(Object? data) parse,
    Object? body,
    bool authenticated = true,
  }) => _send(
    () => _dio.put<dynamic>(path, data: body, options: _options(authenticated)),
    parse,
  );

  Future<ApiResult<T>> patch<T>(
    String path, {
    required T Function(Object? data) parse,
    Object? body,
    bool authenticated = true,
  }) => _send(
    () =>
        _dio.patch<dynamic>(path, data: body, options: _options(authenticated)),
    parse,
  );

  Future<ApiResult<T>> delete<T>(
    String path, {
    required T Function(Object? data) parse,
    Object? body,
    bool authenticated = true,
  }) => _send(
    () => _dio.delete<dynamic>(
      path,
      data: body,
      options: _options(authenticated),
    ),
    parse,
  );

  Options? _options(bool authenticated) =>
      authenticated ? null : Options(extra: const {noAuthKey: true});

  Future<ApiResult<T>> _send<T>(
    Future<Response<dynamic>> Function() send,
    T Function(Object? data) parse,
  ) async {
    final Response<dynamic> response;
    try {
      response = await send();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
    return _parseEnvelope(response.data, parse);
  }

  ApiResult<T> _parseEnvelope<T>(Object? body, T Function(Object? data) parse) {
    if (body is! Map<String, dynamic>) {
      throw const ServerException('Malformed response envelope');
    }
    if (body['success'] != true) {
      throw _envelopeException(body);
    }
    final meta = body['meta'];
    // A 200 whose `data` shape doesn't match what this feature's `parse`
    // expects (e.g. a nested pagination wrapper) throws a raw TypeError here
    // — without this, callers see it as some untyped Object and every screen
    // that switches on ApiException/NetworkException mislabels it.
    final T data;
    try {
      data = parse(body['data']);
    } on ApiException {
      rethrow;
    } on Object catch (e) {
      throw ServerException('Malformed response data: $e');
    }
    return ApiResult(
      data,
      // `meta` is not always pagination: `ApiResponse::success` also ships
      // arbitrary blocks here (e.g. booking cancel returns `{refund: …}`).
      // Only build PaginationMeta when a pagination block is actually present —
      // otherwise `PaginationMeta.fromJson` casts a missing `current_page` and
      // throws a raw TypeError instead of a typed ApiException.
      meta:
          meta is Map<String, dynamic> &&
              (meta['pagination'] != null || meta['current_page'] != null)
          ? PaginationMeta.fromJson(meta)
          : null,
    );
  }

  ApiException _mapDioException(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      return _envelopeException(body);
    }
    final status = e.response?.statusCode;
    if (status != null) return ServerException('HTTP $status');
    return const NetworkException();
  }

  ApiException _envelopeException(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is! Map<String, dynamic>) {
      return const ServerException('Malformed error envelope');
    }
    return apiExceptionFromEnvelope(error);
  }
}
