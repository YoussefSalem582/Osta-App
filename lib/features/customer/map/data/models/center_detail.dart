import 'package:equatable/equatable.dart';

/// Full center profile — mirrors `ServiceCenterResource` (GET
/// `/centers/{center}`). [services] defaults to empty since that relation
/// isn't eager-loaded on `show`.
class CenterDetail extends Equatable {
  const CenterDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.centerType,
    required this.subscriptionTier,
    required this.isActive,
    required this.ratingCount,
    this.description,
    this.latitude,
    this.longitude,
    this.workingHours,
    this.phone,
    this.email,
    this.whatsapp,
    this.addressLine,
    this.city,
    this.district,
    this.logoUrl,
    this.coverUrl,
    this.rating,
    this.timezone,
    this.servicesCount,
    this.reviewsCount,
    this.services = const [],
    this.createdAt,
  });

  factory CenterDetail.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final geo = location is Map<String, dynamic>
        ? location
        : const <String, dynamic>{};
    return CenterDetail(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      centerType: json['center_type'] as String? ?? '',
      subscriptionTier: json['subscription_tier'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      ratingCount: _toInt(json['rating_count']) ?? 0,
      description: json['description'] as String?,
      latitude: _toDouble(geo['latitude']),
      longitude: _toDouble(geo['longitude']),
      workingHours: _workingHours(json['working_hours']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      whatsapp: json['whatsapp'] as String?,
      addressLine: json['address_line'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      rating: _toDouble(json['rating']),
      timezone: json['timezone'] as String?,
      servicesCount: _toInt(json['services_count']),
      reviewsCount: _toInt(json['reviews_count']),
      services: (json['services'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CenterService.fromJson)
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final String id;
  final String name;
  final String slug;
  final String centerType;
  final String subscriptionTier;
  final bool isActive;
  final int ratingCount;
  final String? description;
  final double? latitude;
  final double? longitude;

  /// Lowercase 3-letter day → `[open, close]` time strings, e.g.
  /// `{"mon": ["09:00", "18:00"]}`. Absent/empty days are dropped.
  final Map<String, List<String>>? workingHours;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final String? addressLine;
  final String? city;
  final String? district;
  final String? logoUrl;
  final String? coverUrl;
  final double? rating;

  /// IANA timezone; the backend falls back to the app default when resolving
  /// availability, so this can be null on older records.
  final String? timezone;
  final int? servicesCount;
  final int? reviewsCount;

  /// Only populated when the backend eager-loads the relation (not on `show`).
  final List<CenterService> services;
  final DateTime? createdAt;

  bool get hasPosition => latitude != null && longitude != null;

  static double? _toDouble(Object? v) =>
      v == null ? null : num.tryParse(v.toString())?.toDouble();

  static int? _toInt(Object? v) =>
      v == null ? null : num.tryParse(v.toString())?.toInt();

  static Map<String, List<String>>? _workingHours(Object? raw) {
    if (raw is! Map) return null;
    final out = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        out[key.toString()] = value.map((e) => e.toString()).toList();
      }
    });
    return out.isEmpty ? null : out;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    centerType,
    subscriptionTier,
    isActive,
    ratingCount,
    description,
    latitude,
    longitude,
    workingHours,
    phone,
    email,
    whatsapp,
    addressLine,
    city,
    district,
    logoUrl,
    coverUrl,
    rating,
    timezone,
    servicesCount,
    reviewsCount,
    services,
    createdAt,
  ];
}

/// One offered service — mirrors `ServiceResource` (osta_backend). Reused for
/// both the standalone `/centers/{center}/services` list and the nested
/// `services` key on a loaded [CenterDetail]; the element shape is identical.
class CenterService extends Equatable {
  const CenterService({
    required this.id,
    required this.name,
    required this.price,
    required this.priceType,
    required this.isActive,
    this.description,
    this.category,
    this.durationMinutes,
    this.createdAt,
  });

  factory CenterService.fromJson(Map<String, dynamic> json) => CenterService(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    price: num.tryParse(json['price'].toString())?.toDouble() ?? 0,
    priceType: json['price_type'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? true,
    description: json['description'] as String?,
    category: json['category'] as String?,
    durationMinutes: num.tryParse(
      json['duration_minutes'].toString(),
    )?.toInt(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );

  final String id;
  final String name;
  final double price;

  /// One of `fixed`, `starting_from`, `hourly`.
  final String priceType;
  final bool isActive;
  final String? description;
  final String? category;
  final int? durationMinutes;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    priceType,
    isActive,
    description,
    category,
    durationMinutes,
    createdAt,
  ];
}

/// A center's bookable slots for one day (GET
/// `/centers/{center}/availability?date=Y-m-d`); closed days come back with
/// `is_open: false` and empty [slots].
class CenterAvailability extends Equatable {
  const CenterAvailability({
    required this.date,
    required this.timezone,
    required this.isOpen,
    this.slots = const [],
  });

  factory CenterAvailability.fromJson(Map<String, dynamic> json) =>
      CenterAvailability(
        date: json['date'] as String? ?? '',
        timezone: json['timezone'] as String? ?? '',
        isOpen: json['is_open'] as bool? ?? false,
        slots: (json['slots'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AvailabilitySlot.fromJson)
            .toList(),
      );

  final String date;
  final String timezone;
  final bool isOpen;
  final List<AvailabilitySlot> slots;

  @override
  List<Object?> get props => [date, timezone, isOpen, slots];
}

/// One time slot — mirrors `App\Domain\Center\Data\AvailabilitySlot`.
/// [start]/[end] are ISO-8601 with a tz offset; [available] is false when the
/// slot is in the past or overlapped by an active booking.
class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.available,
    this.start,
    this.end,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlot(
        available: json['available'] as bool? ?? false,
        start: DateTime.tryParse(json['start'] as String? ?? ''),
        end: DateTime.tryParse(json['end'] as String? ?? ''),
      );

  final bool available;
  final DateTime? start;
  final DateTime? end;

  @override
  List<Object?> get props => [available, start, end];
}
