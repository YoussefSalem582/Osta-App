import 'package:equatable/equatable.dart';

/// A customer delivery address (B2C `/me/addresses`). Plain immutable model,
/// hand-written JSON mapping that mirrors `AddressResource` on the backend
/// (flat, 18 keys, no nested objects; `user_id` is not exposed).
class Address extends Equatable {
  const Address({
    required this.id,
    required this.label,
    required this.isDefault,
    this.latitude,
    this.longitude,
    this.line1,
    this.line2,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.city,
    this.district,
    this.landmark,
    this.note,
    this.recipientName,
    this.recipientPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id']?.toString() ?? '',
    label: json['label'] as String? ?? 'other',
    isDefault: json['is_default'] as bool? ?? false,
    latitude: _toDouble(json['latitude']),
    longitude: _toDouble(json['longitude']),
    line1: json['line1'] as String?,
    line2: json['line2'] as String?,
    buildingNumber: json['building_number'] as String?,
    floorNumber: json['floor_number'] as String?,
    apartmentNumber: json['apartment_number'] as String?,
    city: json['city'] as String?,
    district: json['district'] as String?,
    landmark: json['landmark'] as String?,
    note: json['note'] as String?,
    recipientName: json['recipient_name'] as String?,
    recipientPhone: json['recipient_phone'] as String?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );

  final String id;

  /// Enum value: `home` | `work` | `other`.
  final String label;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? line1;
  final String? line2;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? city;
  final String? district;
  final String? landmark;
  final String? note;
  final String? recipientName;
  final String? recipientPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static double? _toDouble(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };

  @override
  List<Object?> get props => [
    id,
    label,
    isDefault,
    latitude,
    longitude,
    line1,
    line2,
    buildingNumber,
    floorNumber,
    apartmentNumber,
    city,
    district,
    landmark,
    note,
    recipientName,
    recipientPhone,
    createdAt,
    updatedAt,
  ];
}
