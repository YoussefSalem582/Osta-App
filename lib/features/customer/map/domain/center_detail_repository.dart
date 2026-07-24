import 'package:osta/features/customer/map/data/models/center_detail.dart';

/// Detail reads for a single center (`show` / `availability` / `services`);
/// errors aren't caught here since `ApiClient` already throws a typed
/// `ApiException` — the caller owns try/catch.
abstract interface class CenterDetailRepository {
  /// Full center profile. GET `/centers/{center}` (`centers.show`). A
  /// suspended/inactive center 404s server-side as `ApiException`.
  Future<CenterDetail> detail(Object id);

  /// Bookable slots for one day. GET `/centers/{center}/availability`.
  /// [date] is required, `Y-m-d`, and must be today .. today+max_advance_days.
  Future<CenterAvailability> availability(Object id, {required String date});

  /// Active services offered by the center, ordered by category then name.
  /// GET `/centers/{center}/services` — not paginated, so a plain list.
  Future<List<CenterService>> services(Object id);
}
