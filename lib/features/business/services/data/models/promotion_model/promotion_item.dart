class PromotionItem {
  String? id;
  String? title;
  String? subtitle;
  dynamic description;
  int? discountPercentage;
  int? discountAmount;
  bool? isActive;
  String? startDate;
  String? endDate;
  String? createdAt;

  PromotionItem({
    this.id,
    this.title,
    this.subtitle,
    this.description,
    this.discountPercentage,
    this.discountAmount,
    this.isActive,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory PromotionItem.fromJson(Map<String, dynamic> json) => PromotionItem(
    id: json['id'] as String?,
    title: json['title'] as String?,
    subtitle: json['subtitle'] as String?,
    description: json['description'] as dynamic,
    discountPercentage: json['discount_percentage'] as int?,
    discountAmount: json['discount_amount'] as int?,
    isActive: json['is_active'] as bool?,
    startDate: json['start_date'] as String?,
    endDate: json['end_date'] as String?,
    createdAt: json['created_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'discount_percentage': discountPercentage,
    'discount_amount': discountAmount,
    'is_active': isActive,
    'start_date': startDate,
    'end_date': endDate,
    'created_at': createdAt,
  };
}
