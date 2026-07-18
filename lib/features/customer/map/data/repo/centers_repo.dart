import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';

/// Discovery reads for the customer map; errors aren't caught here since
/// [ApiClient] already throws typed `ApiException` — `MapBloc` owns try/catch.
class CentersRepository {
  const CentersRepository(this._api);

  final ApiClient _api;

  /// Nearest-first centers around a point. [category] maps to the backend's
  /// `service` query param (matches `services.category`, not a field on the
  /// center itself).
  Future<List<CenterSummary>> nearby({
    required double lat,
    required double lng,
    String? category,
  }) async {
    final result = await _api.get<List<CenterSummary>>(
      ApiEndpoints.centersNearby,
      query: {
        'lat': lat,
        'lng': lng,
        // 50 km — the backend's hard max (`radius|max:50000`); requesting more
        // 422s. Widest discovery allowed, so sparse/seeded centers still
        // surface across greater Cairo.
        'radius': 50000,
        'service': ?category,
      },
      parse: _parseList,
    );
    return result.data;
  }

  /// Free-text search over centers (backend orders these by rating).
  Future<List<CenterSummary>> search({
    required String query,
    String? category,
  }) async {
    final result = await _api.get<List<CenterSummary>>(
      ApiEndpoints.centersSearch,
      query: {'q': query, 'service': ?category},
      parse: _parseList,
    );
    return result.data;
  }

  static List<CenterSummary> _parseList(Object? data) =>
      (data as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CenterSummary.fromJson)
          .toList();
}
