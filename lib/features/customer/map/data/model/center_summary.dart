import 'package:equatable/equatable.dart';

/// One service center as returned by `/centers/nearby` and `/centers/search`.
///
/// The epic documents the fields (name, rating, distance, open-now, coords)
/// but not the JSON spelling, and the endpoints need a bearer token so the
/// contract could not be verified against the live backend. Every field past
/// `id`/`name` therefore stays nullable and accepts the plausible key
/// spellings; the UI null-coalesces at the boundary. Tighten this once a real
/// payload is captured.
class CenterSummary extends Equatable {
  const CenterSummary({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.rating,
    this.distanceMeters,
    this.isOpenNow,
    this.price,
    this.category,
    this.imageUrl,
  });

  factory CenterSummary.fromJson(Map<String, dynamic> json) {
    // osta_backend's `ServiceCenterResource` nests coordinates under a
    // `location: {latitude, longitude}` object rather than flat top-level
    // keys — fall back to `json` itself in case a future response flattens it.
    final location = json['location'];
    final geo = location is Map<String, dynamic> ? location : json;
    return CenterSummary(
      id: json['id']?.toString() ?? '',
      name: _string(json, const ['name', 'title']) ?? '',
      latitude: _double(geo, const ['lat', 'latitude']),
      longitude: _double(geo, const ['lng', 'lon', 'longitude']),
      rating: _double(json, const ['rating', 'average_rating', 'rating_avg']),
      distanceMeters: _double(json, const ['distance_meters', 'distance']),
      isOpenNow: _bool(json, const ['open_now', 'is_open_now', 'is_open']),
      price: _double(json, const ['price', 'starting_price', 'price_from']),
      category: _string(json, const ['category', 'type', 'center_type']),
      imageUrl: _string(json, const [
        'image_url',
        'logo_url',
        'image',
        'logo',
        'thumbnail',
      ]),
    );
  }

  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final double? distanceMeters;
  final bool? isOpenNow;
  final double? price;
  final String? category;
  final String? imageUrl;

  /// Only a center with coordinates can become a marker.
  bool get hasPosition => latitude != null && longitude != null;

  double? get distanceKm {
    final meters = distanceMeters;
    return meters == null ? null : meters / 1000;
  }

  // ponytail: no toJson — nothing ever writes a center back to the API.

  static String? _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static double? _double(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      // Laravel/PostGIS commonly serialize decimals as strings.
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static bool? _bool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value == 'true' || value == 'false') return value == 'true';
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    latitude,
    longitude,
    rating,
    distanceMeters,
    isOpenNow,
    price,
    category,
    imageUrl,
  ];
}
