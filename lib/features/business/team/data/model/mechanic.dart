import 'package:equatable/equatable.dart';

/// A mechanic on a business owner's service-center roster (B2B #58). Plain
/// immutable model; hand-written JSON mapping mirrors `MechanicResource`
/// (`toArray`) on the backend — flat, no nested objects.
class Mechanic extends Equatable {
  const Mechanic({
    required this.id,
    required this.serviceCenterId,
    required this.name,
    required this.specialty,
    required this.isActive,
    this.phone,
    this.photo,
    this.createdAt,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) => Mechanic(
    id: _toInt(json['id']),
    serviceCenterId: _toInt(json['service_center_id']),
    name: json['name'] as String? ?? '',
    specialty: json['specialty'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? false,
    phone: json['phone'] as String?,
    photo: json['photo'] as String?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );

  final int id;
  final int serviceCenterId;
  final String name;
  final String specialty;
  final bool isActive;
  final String? phone;
  final String? photo;
  final DateTime? createdAt;

  static int _toInt(Object? value) =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  @override
  List<Object?> get props => [
    id,
    serviceCenterId,
    name,
    specialty,
    isActive,
    phone,
    photo,
    createdAt,
  ];
}
