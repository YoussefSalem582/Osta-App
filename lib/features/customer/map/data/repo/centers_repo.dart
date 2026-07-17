import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';

/// Discovery reads for the customer map.
///
/// [ApiClient] already throws a typed `ApiException` on failure, so nothing is
/// caught here — `MapBloc` owns the try/catch and turns it into a state.
class CentersRepository {
  const CentersRepository(this._api);

  final ApiClient _api;

  /// Nearest-first centers around a point (PostGIS-ordered by the backend).
  ///
  /// [category] maps to the backend's `service` query param — it matches
  /// against each center's offered `services.category` (see
  /// `FiltersDiscoveryQuery::applyServiceFilter` in osta_backend), not a
  /// `category` field on the center itself, which doesn't exist.
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
        // 25 km default — backend PostGIS radius in metres; widens discovery
        // within Egypt without changing the contract when omitted server-side.
        'radius': 25000,
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
