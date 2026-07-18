class Datum {
  String? id;
  String? name;
  dynamic description;
  dynamic category;
  int? price;
  String? priceType;
  int? durationMinutes;
  bool? isActive;
  String? createdAt;

  Datum({
    this.id,
    this.name,
    this.description,
    this.category,
    this.price,
    this.priceType,
    this.durationMinutes,
    this.isActive,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json['id']?.toString(),
    name: json['name']?.toString(),
    description: json['description'],
    category: json['category'],
    price: json['price'] is String
        ? int.tryParse(json['price'] as String)
        : (json['price'] as num?)?.toInt(),
    priceType: json['price_type']?.toString(),
    durationMinutes: json['duration_minutes'] is String
        ? int.tryParse(json['duration_minutes'] as String)
        : (json['duration_minutes'] as num?)?.toInt(),
    isActive:
        json['is_active'] == 1 ||
        json['is_active'] == true ||
        json['is_active'] == '1' ||
        json['is_active'] == 'true',
    createdAt: json['created_at']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'price_type': priceType,
    'duration_minutes': durationMinutes,
    'is_active': isActive,
    'created_at': createdAt,
  };
}
