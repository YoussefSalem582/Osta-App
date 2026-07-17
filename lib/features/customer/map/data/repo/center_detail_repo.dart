import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/map/data/model/center_detail.dart';

/// Detail reads for a single service center — mirrors osta_backend
/// `CenterController` (`show` / `availability` / `services`).
///
/// Static like the other customer feature repos; [ApiClient] already throws a
/// typed `ApiException`, so nothing is caught here — the cubit owns try/catch.
/// Kept separate from `CentersRepository` (discovery/list reads) on purpose.
abstract final class CenterDetailRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  /// Full center profile. GET `/centers/{center}` (`centers.show`). A
  /// suspended/inactive center 404s server-side as `ApiException`.
  static Future<CenterDetail> detail(Object id) async {
    final result = await _api.get<CenterDetail>(
      ApiEndpoints.center(id),
      parse: (data) => CenterDetail.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// Bookable slots for one day. GET `/centers/{center}/availability`.
  /// [date] is required, `Y-m-d`, and must be today .. today+max_advance_days.
  static Future<CenterAvailability> availability(
    Object id, {
    required String date,
  }) async {
    final result = await _api.get<CenterAvailability>(
      ApiEndpoints.centerAvailability(id),
      query: {'date': date},
      parse: (data) =>
          CenterAvailability.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// Active services offered by the center, ordered by category then name.
  /// GET `/centers/{center}/services` — not paginated, so a plain list.
  static Future<List<CenterService>> services(Object id) async {
    final result = await _api.get<List<CenterService>>(
      ApiEndpoints.centerServices(id),
      parse: (data) => (data as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CenterService.fromJson)
          .toList(),
    );
    return result.data;
  }
}
