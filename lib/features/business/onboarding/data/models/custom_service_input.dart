import 'package:equatable/equatable.dart';

/// A service the merchant typed in themselves, for `POST /business/services`.
///
/// Deliberately not a catalog preset: `POST /business/catalog` validates
/// `items.*.preset_id` as `required|uuid|exists:catalog_presets,id`, so a
/// service with no preset row physically cannot go through the catalog
/// endpoint. Field names match `StoreServiceRequest`.
class CustomServiceInput extends Equatable {
  const CustomServiceInput({
    required this.name,
    required this.price,
    this.category,
    this.durationMinutes,
  });

  /// Round-trips [toJson] out of the persisted wizard draft. The keys double as
  /// the wire format, so there is only one shape to keep in step.
  factory CustomServiceInput.fromJson(Map<String, dynamic> json) =>
      CustomServiceInput(
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String?,
        durationMinutes: json['duration_minutes'] as int?,
      );

  final String name;

  /// EGP. Backend: `numeric|min:0|max:99999999.99`.
  final double price;

  final String? category;

  /// Backend: `integer|min:1|max:1440`.
  final int? durationMinutes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    if (category != null && category!.isNotEmpty) 'category': category,
    'duration_minutes': ?durationMinutes,
  };

  @override
  List<Object?> get props => [name, price, category, durationMinutes];
}
