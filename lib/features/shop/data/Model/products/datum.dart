import 'owner.dart';

class Datum {
  String? id;
  String? name;
  String? description;
  String? category;
  int? price;
  List<dynamic>? images;
  String? status;
  Owner? owner;
  String? createdAt;

  Datum({
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
}
