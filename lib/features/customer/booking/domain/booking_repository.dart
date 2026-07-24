import 'package:osta/core/network/api_client.dart';
import 'package:osta/features/customer/booking/data/models/booking.dart';

/// Contract for the customer booking funnel (`/bookings`); errors aren't
/// caught here since `ApiClient` already throws typed `ApiException` — the
/// blocs own try/catch.
abstract interface class BookingRepository {
  /// Paginated list, server-filtered by [status] (`upcoming` / `past`).
  Future<ApiResult<List<Booking>>> list({String? status, int? perPage});

  Future<Booking> show(Object id);

  Future<Booking> create({
    required String serviceCenterId,
    required DateTime scheduledAt,
    required List<String> serviceIds,
    String? vehicleId,
    String? notes,
  });

  Future<Booking> confirm(Object id);

  Future<Booking> reschedule(Object id, DateTime scheduledAt);

  Future<Booking> cancel(Object id, {String? reason});
}
