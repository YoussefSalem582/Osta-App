import 'package:equatable/equatable.dart';

/// One seeded catalog preset from `GET /business/catalog/presets`.
class CatalogPreset extends Equatable {
  const CatalogPreset({
    required this.id,
    required this.category,
    required this.name,
    required this.defaultPrice,
    required this.defaultDurationMinutes,
    this.categoryLabel,
  });

  factory CatalogPreset.fromJson(Map<String, dynamic> json) => CatalogPreset(
    id: json['id']?.toString() ?? '',
    category: (json['category'] as String?) ?? '',
    categoryLabel: json['category_label'] as String?,
    name: (json['name'] as String?) ?? '',
    defaultPrice: _num(json['default_price']),
    defaultDurationMinutes: _int(json['default_duration_minutes']),
  );

  final String id;

  /// Wire category key: `oil` / `brakes` / `ac`.
  final String category;

  /// Localized label from the server (`Accept-Language`).
  final String? categoryLabel;

  final String name;
  final double defaultPrice;
  final int defaultDurationMinutes;

  static double _num(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    category,
    categoryLabel,
    name,
    defaultPrice,
    defaultDurationMinutes,
  ];
}
