import 'package:equatable/equatable.dart';

/// A booking as seen by the center owner (B2B); mirrors backend
/// `BookingResource`. [customer]/[mechanic]/[assignedMechanic]/[items] are
/// `null` both when not eager-loaded and when genuinely absent — only trust
/// "unassigned" if the endpoint loaded the relation.
class BusinessBooking extends Equatable {
  const BusinessBooking({
    required this.id,
    required this.reference,
    required this.status,
    this.scheduledAt,
    this.scheduledEndAt,
    this.confirmedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    this.totalAmount,
    this.notes,
    this.vehicleId,
    this.customer,
    this.mechanic,
    this.assignedMechanic,
    this.items,
    this.createdAt,
  });

  factory BusinessBooking.fromJson(Map<String, dynamic> json) =>
      BusinessBooking(
        id: json['id']?.toString() ?? '',
        reference: json['reference'] as String? ?? '',
        status: json['status'] as String? ?? '',
        scheduledAt: _date(json['scheduled_at']),
        scheduledEndAt: _date(json['scheduled_end_at']),
        confirmedAt: _date(json['confirmed_at']),
        startedAt: _date(json['started_at']),
        completedAt: _date(json['completed_at']),
        cancelledAt: _date(json['cancelled_at']),
        cancellationReason: json['cancellation_reason'] as String?,
        cancelledBy: json['cancelled_by']?.toString(),
        totalAmount: _toDouble(json['total_amount']),
        notes: json['notes'] as String?,
        vehicleId: json['vehicle_id']?.toString(),
        customer: _party(json['customer']),
        mechanic: _party(json['mechanic']),
        assignedMechanic: json['assigned_mechanic'] is Map<String, dynamic>
            ? BookingRosterMechanic.fromJson(
                json['assigned_mechanic'] as Map<String, dynamic>,
              )
            : null,
        items: json['items'] is List
            ? (json['items'] as List<dynamic>)
                  .map(
                    (e) => BusinessBookingService.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList()
            : null,
        createdAt: _date(json['created_at']),
      );

  final String id;
  final String reference;

  /// One of `pending`, `confirmed`, `in_progress`, `completed`, `cancelled`,
  /// `invoiced` (backend `BookingStatus` enum).
  final String status;

  /// Always sent by the backend; `null` only if the timestamp fails to parse.
  final DateTime? scheduledAt;
  final DateTime? scheduledEndAt;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final double? totalAmount;
  final String? notes;
  final String? vehicleId;

  /// Booking customer (`{id, name}`); `null` when not eager-loaded.
  final BookingParty? customer;

  /// The *user*-type mechanic (`{id, name}`); `null` when unassigned **or**
  /// when not eager-loaded.
  final BookingParty? mechanic;

  /// The *roster* mechanic (`mechanics` table, distinct from [mechanic]);
  /// `null` when unassigned **or** not eager-loaded.
  final BookingRosterMechanic? assignedMechanic;

  /// Line items; `null` when not eager-loaded.
  final List<BusinessBookingService>? items;
  final DateTime? createdAt;

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  static double? _toDouble(Object? v) => switch (v) {
    null => null,
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };

  static BookingParty? _party(Object? v) =>
      v is Map<String, dynamic> ? BookingParty.fromJson(v) : null;

  @override
  List<Object?> get props => [
    id,
    reference,
    status,
    scheduledAt,
    scheduledEndAt,
    confirmedAt,
    startedAt,
    completedAt,
    cancelledAt,
    cancellationReason,
    cancelledBy,
    totalAmount,
    notes,
    vehicleId,
    customer,
    mechanic,
    assignedMechanic,
    items,
    createdAt,
  ];
}

/// A `{id, name}` reference used for a booking's `customer` and (user-type)
/// `mechanic`.
class BookingParty extends Equatable {
  const BookingParty({required this.id, required this.name});

  factory BookingParty.fromJson(Map<String, dynamic> json) => BookingParty(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
  );

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// A roster mechanic (`mechanics` table) attached to a booking as
/// `assigned_mechanic` — carries an optional [specialty].
class BookingRosterMechanic extends Equatable {
  const BookingRosterMechanic({
    required this.id,
    required this.name,
    this.specialty,
  });

  factory BookingRosterMechanic.fromJson(Map<String, dynamic> json) =>
      BookingRosterMechanic(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        specialty: json['specialty'] as String?,
      );

  final String id;
  final String name;
  final String? specialty;

  @override
  List<Object?> get props => [id, name, specialty];
}

/// A booking line item — mirrors `BookingServiceResource`
/// (app/Http/Resources/Api/B2C/BookingServiceResource.php).
class BusinessBookingService extends Equatable {
  const BusinessBookingService({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory BusinessBookingService.fromJson(Map<String, dynamic> json) =>
      BusinessBookingService(
        serviceId: json['service_id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        price: _toDouble(json['price']),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      );

  final String serviceId;
  final String name;
  final double price;
  final int quantity;

  static double _toDouble(Object? v) => switch (v) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s) ?? 0,
    _ => 0,
  };

  @override
  List<Object?> get props => [serviceId, name, price, quantity];
}
