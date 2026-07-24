import 'package:equatable/equatable.dart';

class BookingService extends Equatable {
  const BookingService({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) => BookingService(
    serviceId: json['service_id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    price: _toDoubleOrNull(json['price']) ?? 0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  );

  final String serviceId;
  final String name;
  final double price;
  final int quantity;

  @override
  List<Object?> get props => [serviceId, name, price, quantity];
}

class BookingCenter extends Equatable {
  const BookingCenter({
    required this.id,
    required this.name,
    required this.city,
    required this.phone,
    this.logoUrl,
  });

  factory BookingCenter.fromJson(Map<String, dynamic> json) => BookingCenter(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    city: json['city'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    logoUrl: json['logo_url'] as String?,
  );

  final String id;
  final String name;
  final String city;
  final String phone;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, city, phone, logoUrl];
}

class BookingMechanic extends Equatable {
  const BookingMechanic({required this.id, required this.name, this.specialty});

  factory BookingMechanic.fromJson(Map<String, dynamic> json) =>
      BookingMechanic(
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

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.reference,
    required this.status,
    this.scheduledAt,
    this.scheduledEndAt,
    this.holdExpiresAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    this.totalAmount,
    this.notes,
    this.vehicleId,
    this.items,
    this.center,
    this.assignedMechanic,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id']?.toString() ?? '',
    reference: json['reference'] as String? ?? '',
    status: json['status'] as String? ?? '',
    scheduledAt: _toDate(json['scheduled_at']),
    scheduledEndAt: _toDate(json['scheduled_end_at']),
    holdExpiresAt: _toDate(json['hold_expires_at']),
    confirmedAt: _toDate(json['confirmed_at']),
    cancelledAt: _toDate(json['cancelled_at']),
    cancellationReason: json['cancellation_reason'] as String?,
    cancelledBy: json['cancelled_by']?.toString(),
    totalAmount: _toDoubleOrNull(json['total_amount']),
    notes: json['notes'] as String?,
    vehicleId: json['vehicle_id']?.toString(),
    // whenLoaded: key absent when the relation wasn't eager-loaded; null keeps
    // "not loaded" distinct from "loaded but empty".
    items: json['items'] is List
        ? (json['items'] as List<dynamic>)
              .map((e) => BookingService.fromJson(e as Map<String, dynamic>))
              .toList()
        : null,
    center: json['center'] is Map<String, dynamic>
        ? BookingCenter.fromJson(json['center'] as Map<String, dynamic>)
        : null,
    assignedMechanic: json['assigned_mechanic'] is Map<String, dynamic>
        ? BookingMechanic.fromJson(
            json['assigned_mechanic'] as Map<String, dynamic>,
          )
        : null,
    createdAt: _toDate(json['created_at']),
  );

  final String id;
  final String reference;

  final String status;
  final DateTime? scheduledAt;
  final DateTime? scheduledEndAt;

  final DateTime? holdExpiresAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final double? totalAmount;
  final String? notes;
  final String? vehicleId;
  final List<BookingService>? items;
  final BookingCenter? center;
  final BookingMechanic? assignedMechanic;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    reference,
    status,
    scheduledAt,
    scheduledEndAt,
    holdExpiresAt,
    confirmedAt,
    cancelledAt,
    cancellationReason,
    cancelledBy,
    totalAmount,
    notes,
    vehicleId,
    items,
    center,
    assignedMechanic,
    createdAt,
  ];
}

double? _toDoubleOrNull(Object? value) => switch (value) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

DateTime? _toDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
