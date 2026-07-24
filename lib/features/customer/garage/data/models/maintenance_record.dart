import 'package:equatable/equatable.dart';

/// A single vehicle maintenance/expense entry (mirrors the backend resource).
/// `receipt_url` is a short-lived signed URL — do not cache/persist it.
class MaintenanceRecord extends Equatable {
  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.typeLabel,
    required this.source,
    required this.isEditable,
    this.bookingId,
    this.serviceCenterId,
    this.description,
    this.mileage,
    this.cost,
    this.performedAt,
    this.receiptUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) =>
      MaintenanceRecord(
        id: json['id']?.toString() ?? '',
        vehicleId: json['vehicle_id']?.toString() ?? '',
        bookingId: json['booking_id']?.toString(),
        serviceCenterId: json['service_center_id']?.toString(),
        type: json['type'] as String? ?? '',
        typeLabel: json['type_label'] as String? ?? '',
        description: json['description'] as String?,
        mileage: _toInt(json['mileage']),
        cost: _toDouble(json['cost']),
        performedAt: _date(json['performed_at']),
        receiptUrl: json['receipt_url'] as String?,
        source: json['source'] as String? ?? 'manual',
        isEditable: json['is_editable'] as bool? ?? false,
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );

  final String id;
  final String vehicleId;
  final String? bookingId;
  final String? serviceCenterId;

  /// `ExpenseCategory`: fuel / parts / salary / rent / utilities / other.
  final String type;
  final String typeLabel;
  final String? description;
  final int? mileage;
  final double? cost;

  /// Date-only (`YYYY-MM-DD`) on the wire.
  final DateTime? performedAt;

  /// Signed temporary URL; null when no receipt. Do not persist.
  final String? receiptUrl;

  /// `MaintenanceSource`: `manual` or `booking`.
  final String source;

  /// True only for `manual` records; booking-sourced ones are read-only.
  final bool isEditable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isManual => source == 'manual';

  static int? _toInt(Object? v) =>
      v == null ? null : num.tryParse(v.toString())?.toInt();

  static double? _toDouble(Object? v) =>
      v == null ? null : num.tryParse(v.toString())?.toDouble();

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    bookingId,
    serviceCenterId,
    type,
    typeLabel,
    description,
    mileage,
    cost,
    performedAt,
    receiptUrl,
    source,
    isEditable,
    createdAt,
    updatedAt,
  ];
}
