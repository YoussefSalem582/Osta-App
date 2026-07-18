import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';

/// Dashboard + capacity endpoints; center is resolved server-side, so no ids
/// are passed.
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

  /// Partial update: null field = unchanged, `[]` = clear. `slots` maps day to
  /// `[open, close]`; `breaks` maps day to `[[start, end]]`; `holidays` are
  /// `Y-m-d`.
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
