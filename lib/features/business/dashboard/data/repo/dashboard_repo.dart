import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';

/// Data layer for the business dashboard + capacity endpoints
/// (`DashboardController@index`, `BusinessCapacityController@update`). Static
/// like the other repos; the center is resolved server-side from the
/// authenticated user, so no ids are passed. Errors bubble as `ApiException`.
abstract final class DashboardRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  /// Today/pending/completed counts + revenue for the caller's center.
  static Future<BusinessDashboard> dashboard() async {
    final result = await _api.get<BusinessDashboard>(
      ApiEndpoints.businessDashboard,
      parse: (data) =>
          BusinessDashboard.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// Partial capacity update. Semantics per field: **null → leave unchanged**,
  /// **`[]` → clear**. Omitting a param sends nothing for it. `slots` maps a
  /// 3-letter day to `[open, close]`; `breaks` maps a day to `[[start, end]]`;
  /// `holidays` is `Y-m-d` strings. Returns the refreshed profile.
  static Future<BusinessProfile> updateCapacity({
    Map<String, List<String>>? slots,
    Map<String, List<List<String>>>? breaks,
    List<String>? holidays,
  }) async {
    final result = await _api.put<BusinessProfile>(
      ApiEndpoints.businessCapacity,
      body: {'slots': ?slots, 'breaks': ?breaks, 'holidays': ?holidays},
      parse: (data) => BusinessProfile.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }
}
