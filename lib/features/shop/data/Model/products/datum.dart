import 'package:equatable/equatable.dart';
import 'package:osta/features/shop/data/Model/products/owner.dart';

class Datum extends Equatable {
  const Datum({
    this.id,
    this.name,
    this.description,
    this.category,
    this.price,
    this.images,
    this.status,
    this.owner,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json['id'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    category: json['category'] as String?,
    price: json['price'] as int?,
    images: json['images'] as List<dynamic>?,
    status: json['status'] as String?,
    owner: json['owner'] == null
        ? null
        : Owner.fromJson(json['owner'] as Map<String, dynamic>),
    createdAt: json['created_at'] as String?,
  );

  final String? id;
  final String? name;
  final String? description;
  final String? category;
  final int? price;
  final List<dynamic>? images;
  final String? status;
  final Owner? owner;
  final String? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'images': images,
    'status': status,
    'owner': owner?.toJson(),
    'created_at': createdAt,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    price,
    images,
    status,
    owner,
    createdAt,
  ];
}
