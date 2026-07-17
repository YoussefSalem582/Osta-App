import 'package:equatable/equatable.dart';

/// A discount promotion on a business owner's service center (B2B). Plain
/// immutable model; hand-written JSON mapping mirrors `PromotionResource`
/// (`toArray`) on the backend — flat, no nested objects. Unlike most B2B
/// resources this one **does** expose `service_center_id`.
class Promotion extends Equatable {
  const Promotion({
    required this.id,
    required this.serviceCenterId,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.redeemedCount,
    required this.isActive,
    this.description,
    this.code,
    this.startsAt,
    this.endsAt,
    this.maxRedemptions,
    this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    id: _toInt(json['id']),
    serviceCenterId: _toInt(json['service_center_id']),
    title: json['title'] as String? ?? '',
    // Backend enum: "percent" | "fixed".
    discountType: json['discount_type'] as String? ?? '',
    // Cast `(float)` server-side, but tolerate int/string just in case.
    discountValue: _toDouble(json['discount_value']),
    redeemedCount: _toInt(json['redeemed_count']),
    isActive: json['is_active'] as bool? ?? false,
    description: json['description'] as String?,
    code: json['code'] as String?,
    // `starts_at` is non-null server-side; kept nullable for defensive parsing.
    startsAt: DateTime.tryParse(json['starts_at'] as String? ?? ''),
    endsAt: DateTime.tryParse(json['ends_at'] as String? ?? ''),
    maxRedemptions: (json['max_redemptions'] as num?)?.toInt(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );

  final int id;
  final int serviceCenterId;
  final String title;

  /// `"percent"` | `"fixed"`.
  final String discountType;
  final double discountValue;
  final int redeemedCount;
  final bool isActive;
  final String? description;
  final String? code;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? maxRedemptions;
  final DateTime? createdAt;

  static int _toInt(Object? value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  static double _toDouble(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s) ?? 0,
    _ => 0,
  };

  @override
  List<Object?> get props => [
    id,
    serviceCenterId,
    title,
    discountType,
    discountValue,
    redeemedCount,
    isActive,
    description,
    code,
    startsAt,
    endsAt,
    maxRedemptions,
    createdAt,
  ];
}
