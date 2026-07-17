import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/notifications/data/model/app_notification.dart';

/// Data layer over the notification feed (`NotificationController` /
/// `NotificationResource`). Static methods like the other repos; errors bubble
/// up as the typed `ApiException`.
abstract final class NotificationRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<AppNotification> _parseList(Object? data) =>
      (data! as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();

  static AppNotification _parseOne(Object? data) =>
      AppNotification.fromJson(data! as Map<String, dynamic>);

  /// Newest-first feed for the authenticated user. [perPage] is clamped to
  /// [1, 50] server-side (default 15); [page] is 1-based. Returns the whole
  /// `ApiResult` so callers keep `.meta` for pagination.
  static Future<ApiResult<List<AppNotification>>> list({
    int page = 1,
    int perPage = 15,
  }) => _api.get<List<AppNotification>>(
    ApiEndpoints.notifications,
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  /// Marks [id] read (`markAsRead()` server-side) and returns the refreshed
  /// notification — `read_at` is non-null afterwards. 404 if not owned/absent.
  static Future<AppNotification> markRead(String id) async {
    final result = await _api.post<AppNotification>(
      ApiEndpoints.notificationRead(id),
      parse: _parseOne,
    );
    return result.data;
  }
}
