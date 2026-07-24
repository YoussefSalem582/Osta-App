import 'package:equatable/equatable.dart';

/// The polymorphic owner of a [Product] — a User or a ServiceCenter. The
/// backend exposes a friendly slug in `owner.type` (`user` / `service_center`).
class ProductOwner extends Equatable {
  const ProductOwner({required this.type, this.id, this.name});

  factory ProductOwner.fromJson(Map<String, dynamic> json) => ProductOwner(
    type: json['type'] as String? ?? '',
    id: json['id']?.toString(),
    name: json['name'] as String?,
  );

  final String type;
  final String? id;
  final String? name;

  /// True when the owner is a ServiceCenter (vs a personal User shop) — decides
  /// which storefront endpoint the seller catalog reads.
  bool get isCenter => type == 'service_center';

  @override
  List<Object?> get props => [type, id, name];
}

/// A sellable product in the two-sided Shop (#48): browse-and-enquire only,
/// no cart/checkout. Plain immutable model, hand-written JSON mapping — the
/// repo mirrors `ProductResource` on the backend.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.category,
    this.images = const [],
    this.status = 'active',
    this.owner,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    // Envelope sends a JSON number; tolerate int/double/string.
    price: _toDouble(json['price']),
    description: json['description'] as String?,
    category: json['category'] as String?,
    images: (json['images'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    status: json['status'] as String? ?? 'active',
    owner: json['owner'] is Map<String, dynamic>
        ? ProductOwner.fromJson(json['owner'] as Map<String, dynamic>)
        : null,
    createdAt: json['created_at'] as String?,
  );

  final String id;
  final String name;
  final double price;
  final String? description;
  final String? category;
  final List<String> images;
  final String status;
  final ProductOwner? owner;
  final String? createdAt;

  bool get isActive => status == 'active';

  static double _toDouble(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s) ?? 0,
    _ => 0,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    description,
    category,
    images,
    status,
    owner,
    createdAt,
  ];
}
