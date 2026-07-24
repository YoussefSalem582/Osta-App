import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/booking/data/models/booking.dart';
import 'package:osta/features/customer/booking/domain/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._api);

  final ApiClient _api;

  static List<Booking> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Booking.fromJson(e as Map<String, dynamic>))
      .toList();

  static Booking _parseOne(Object? data) =>
      Booking.fromJson(data! as Map<String, dynamic>);

  @override
  Future<ApiResult<List<Booking>>> list({
    String? status,
    int? perPage,
  }) => _api.get<List<Booking>>(
    ApiEndpoints.bookings,
    parse: _parseList,
    query: {
      'status': ?status,
      'per_page': ?perPage,
    },
  );

  @override
  Future<Booking> show(Object id) async {
    final result = await _api.get<Booking>(
      ApiEndpoints.booking(id),
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<Booking> create({
    required String serviceCenterId,
    required DateTime scheduledAt,
    required List<String> serviceIds,
    String? vehicleId,
    String? notes,
  }) async {
    final result = await _api.post<Booking>(
      ApiEndpoints.bookings,
      body: {
        'service_center_id': serviceCenterId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'service_ids': serviceIds,
        'vehicle_id': ?vehicleId,
        'notes': ?notes,
      },
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<Booking> confirm(Object id) async {
    final result = await _api.post<Booking>(
      ApiEndpoints.bookingConfirm(id),
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<Booking> reschedule(Object id, DateTime scheduledAt) async {
    final result = await _api.patch<Booking>(
      ApiEndpoints.bookingReschedule(id),
      body: {'scheduled_at': scheduledAt.toIso8601String()},
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<Booking> cancel(Object id, {String? reason}) async {
    final result = await _api.post<Booking>(
      ApiEndpoints.bookingCancel(id),
      body: {'reason': ?reason},
      parse: _parseOne,
    );
    return result.data;
  }
}
