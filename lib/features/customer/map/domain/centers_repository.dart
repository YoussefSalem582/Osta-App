import 'package:osta/features/customer/map/data/models/center_summary.dart';

/// Discovery reads for the customer map; errors aren't caught here since
/// `ApiClient` already throws typed `ApiException` — `MapBloc` owns try/catch.
abstract interface class CentersRepository {
  /// Nearest-first centers around a point. [category] maps to the backend's
  /// `service` query param (matches `services.category`, not a field on the
  /// center itself).
  Future<List<CenterSummary>> nearby({
    required double lat,
    required double lng,
    String? category,
  });

  /// Free-text search over centers (backend orders these by rating).
  Future<List<CenterSummary>> search({
    required String query,
    String? category,
  });
}
