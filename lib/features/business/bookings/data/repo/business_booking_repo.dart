import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/bookings/data/model/business_booking.dart';

/// Data layer over the B2B booking endpoints — mirrors `BookingController`
/// (app/Http/Controllers/Api/B2B/BookingController.php) and its
/// `BookingResource`. Static methods like the other repos; errors bubble as the
/// typed `ApiException`. All routes are `auth:sanctum` + `ability:access` and
/// scoped to the caller's service center (`BookingPolicy::operate`).
abstract final class BusinessBookingRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<BusinessBooking> _parseList(Object? data) =>
      (data! as List<dynamic>)
          .map((e) => BusinessBooking.fromJson(e as Map<String, dynamic>))
          .toList();

  static BusinessBooking _parseOne(Object? data) =>
      BusinessBooking.fromJson(data! as Map<String, dynamic>);

  /// Paginated list, soonest first. [date] filters to one calendar day (center
  /// timezone); [status] filters to a single `BookingStatus`. Returns the whole
  /// `ApiResult` so callers keep `.meta` for paging.
  static Future<ApiResult<List<BusinessBooking>>> list({
    DateTime? date,
    String? status,
    int? perPage,
  }) => _api.get<List<BusinessBooking>>(
    ApiEndpoints.businessBookings,
    parse: _parseList,
    query: {
      if (date != null)
        'date':
            '${date.year.toString().padLeft(4, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}',
      'status': ?status,
      'per_page': ?perPage,
    },
  );

  /// `pending → confirmed`. No body.
  static Future<BusinessBooking> accept(Object id) async {
    final result = await _api.patch<BusinessBooking>(
      ApiEndpoints.businessBookingAccept(id),
      parse: _parseOne,
    );
    return result.data;
  }

  /// `pending → cancelled`, recording [reason] (required, max 500 chars).
  static Future<BusinessBooking> reject(Object id, String reason) async {
    final result = await _api.patch<BusinessBooking>(
      ApiEndpoints.businessBookingReject(id),
      body: {'reason': reason},
      parse: _parseOne,
    );
    return result.data;
  }

  /// Forward transition — [status] must be `in_progress` or `completed` (the
  /// backend rejects anything else; accept/reject/cancel have own endpoints).
  static Future<BusinessBooking> updateStatus(
    Object id,
    String status,
  ) async {
    final result = await _api.patch<BusinessBooking>(
      ApiEndpoints.businessBookingStatus(id),
      body: {'status': status},
      parse: _parseOne,
    );
    return result.data;
  }

  /// Assign a *user*-type mechanic ([mechanicId] → `users.id`). Center-staff
  /// membership is enforced server-side, so a valid uuid can still 422.
  static Future<BusinessBooking> assignMechanic(
    Object id,
    String mechanicId,
  ) async {
    final result = await _api.patch<BusinessBooking>(
      ApiEndpoints.businessBookingAssignMechanic(id),
      body: {'mechanic_id': mechanicId},
      parse: _parseOne,
    );
    return result.data;
  }

  /// Assign (or clear) a *roster* mechanic ([mechanicId] → `mechanics.id`, or
  /// `null` to unassign). The key is always sent — an empty body would 422.
  static Future<BusinessBooking> assignRosterMechanic(
    Object id,
    String? mechanicId,
  ) async {
    final result = await _api.patch<BusinessBooking>(
      ApiEndpoints.businessBookingAssignRosterMechanic(id),
      body: {'mechanic_id': mechanicId},
      parse: _parseOne,
    );
    return result.data;
  }
}
