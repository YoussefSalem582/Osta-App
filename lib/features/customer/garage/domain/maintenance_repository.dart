import 'package:osta/core/network/api_client.dart';
import 'package:osta/features/customer/garage/data/models/maintenance_record.dart';

/// Contract for one vehicle's maintenance history (`/vehicles/{id}/maintenance`).
abstract interface class MaintenanceRepository {
  Future<ApiResult<List<MaintenanceRecord>>> history(
    Object vehicleId, {
    int page = 1,
    int perPage = 15,
  });

  Future<MaintenanceRecord> addRecord(
    Object vehicleId, {
    required String type,
    required DateTime performedAt,
    String? description,
    int? mileage,
    double? cost,
    String? receiptPath,
  });

  Future<List<int>> exportPdf(Object vehicleId);
}
