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
				id: json['id'] as String?,
				name: json['name'] as String?,
				description: json['description'] as dynamic,
				category: json['category'] as dynamic,
				price: json['price'] as int?,
				priceType: json['price_type'] as String?,
				durationMinutes: json['duration_minutes'] as int?,
				isActive: json['is_active'] as bool?,
				createdAt: json['created_at'] as String?,
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
