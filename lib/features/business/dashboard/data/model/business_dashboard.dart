import 'package:equatable/equatable.dart';

/// Snapshot for `GET /business/dashboard`. Counts are non-null ints (server
/// coalesces to 0); `revenue` is a float.
class BusinessDashboard extends Equatable {
  const BusinessDashboard({
    required this.today,
    required this.pending,
    required this.completed,
    required this.revenue,
  });

  factory BusinessDashboard.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] as Map<String, dynamic>? ?? const {};
    return BusinessDashboard(
      today: _toInt(counts['today']),
      pending: _toInt(counts['pending']),
      completed: _toInt(counts['completed']),
      revenue: _toDouble(json['revenue']),
    );
  }

  final int today;
  final int pending;
  final int completed;
  final double revenue;

  @override
  List<Object?> get props => [today, pending, completed, revenue];
}

/// Business profile returned by `PUT /business/capacity`; `services` is optional
/// since this endpoint doesn't eager-load it.
class BusinessProfile extends Equatable {
  const BusinessProfile({
    required this.id,
    required this.tradeName,
    required this.businessType,
    required this.location,
    required this.isActive,
    this.legalName,
    this.yearFounded,
    this.phone,
    this.email,
    this.logoUrl,
    this.addressLine,
    this.city,
    this.district,
    this.workingHours,
    this.breaks,
    this.holidays,
    this.createdAt,
    this.services,
  });

  factory BusinessProfile.fromJson(
    Map<String, dynamic> json,
  ) => BusinessProfile(
    id: json['id']?.toString() ?? '',
    tradeName: json['trade_name'] as String? ?? '',
    businessType: json['business_type'] as String? ?? '',
    location: BusinessLocation.fromJson(
      json['location'] as Map<String, dynamic>? ?? const {},
    ),
    isActive: json['is_active'] as bool? ?? false,
    legalName: json['legal_name'] as String?,
    yearFounded: _toIntOrNull(json['year_founded']),
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    logoUrl: json['logo_url'] as String?,
    addressLine: json['address_line'] as String?,
    city: json['city'] as String?,
    district: json['district'] as String?,
    workingHours: _slots(json['working_hours']),
    breaks: _breaks(json['breaks']),
    holidays: _strList(json['holidays']),
    createdAt: _date(json['created_at']),
    // Omitted on the capacity endpoint; parsed when other endpoints load it.
    services: (json['services'] as List<dynamic>?)
        ?.map((e) => BusinessService.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String tradeName;

  /// `CenterType` enum string value (e.g. `workshop`), not an int.
  final String businessType;
  final BusinessLocation location;
  final bool isActive;
  final String? legalName;
  final int? yearFounded;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? addressLine;
  final String? city;
  final String? district;

  /// Saved slots: `{ "sat": ["08:00","22:00"], ... }`.
  final Map<String, List<String>>? workingHours;

  /// Break windows per day: `{ "sat": [["12:00","13:00"], ...], ... }`.
  final Map<String, List<List<String>>>? breaks;
  final List<String>? holidays;
  final DateTime? createdAt;
  final List<BusinessService>? services;

  @override
  List<Object?> get props => [
    id,
    tradeName,
    businessType,
    location,
    isActive,
    legalName,
    yearFounded,
    phone,
    email,
    logoUrl,
    addressLine,
    city,
    district,
    workingHours,
    breaks,
    holidays,
    createdAt,
    services,
  ];
}

/// Center pin — always present as an object; both members null when unset.
class BusinessLocation extends Equatable {
  const BusinessLocation({this.latitude, this.longitude});

  factory BusinessLocation.fromJson(Map<String, dynamic> json) =>
      BusinessLocation(
        latitude: _toDoubleOrNull(json['latitude']),
        longitude: _toDoubleOrNull(json['longitude']),
      );

  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// A center service (`ServiceResource`). Absent on the capacity endpoint; see
/// [BusinessProfile.services].
class BusinessService extends Equatable {
  const BusinessService({
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

  factory BusinessService.fromJson(Map<String, dynamic> json) =>
      BusinessService(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        price: _toDouble(json['price']),
        priceType: json['price_type'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        description: json['description'] as String?,
        category: json['category'] as String?,
        durationMinutes: _toIntOrNull(json['duration_minutes']),
        createdAt: _date(json['created_at']),
      );

  final String id;
  final String name;
  final double price;

  /// `PriceType` enum string value.
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

// ── Shared defensive parsers (envelope numbers arrive as num/String) ──

int _toInt(Object? v) => switch (v) {
  final num n => n.toInt(),
  final String s => int.tryParse(s) ?? 0,
  _ => 0,
};

int? _toIntOrNull(Object? v) => switch (v) {
  final num n => n.toInt(),
  final String s => int.tryParse(s),
  _ => null,
};

double _toDouble(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s) ?? 0,
  _ => 0,
};

double? _toDoubleOrNull(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

List<String>? _strList(Object? v) =>
    v is List ? v.map((e) => e.toString()).toList() : null;

/// `{ day: [open, close] }`.
Map<String, List<String>>? _slots(Object? v) => v is Map
    ? v.map(
        (k, val) => MapEntry(
          k.toString(),
          (val as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        ),
      )
    : null;

/// `{ day: [[start, end], ...] }`.
Map<String, List<List<String>>>? _breaks(Object? v) => v is Map
    ? v.map(
        (k, val) => MapEntry(
          k.toString(),
          (val as List<dynamic>? ?? const [])
              .map(
                (w) => (w as List<dynamic>? ?? const [])
                    .map((e) => e.toString())
                    .toList(),
              )
              .toList(),
        ),
      )
    : null;
