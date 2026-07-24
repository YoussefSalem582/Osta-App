import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/map/data/models/center_summary.dart';
import 'package:osta/features/customer/map/domain/centers_repository.dart';

class CentersRepositoryImpl implements CentersRepository {
  const CentersRepositoryImpl(this._api);

  final ApiClient _api;

  @override
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

  @override
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
