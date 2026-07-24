import 'package:dio/dio.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/garage/data/models/maintenance_record.dart';
import 'package:osta/features/customer/garage/domain/maintenance_repository.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._api, this._dio);

  final ApiClient _api;

  /// PDF export needs raw bytes, which [ApiClient] does not expose.
  final Dio _dio;

  static List<MaintenanceRecord> _parseList(Object? data) =>
      (data! as List<dynamic>)
          .map((e) => MaintenanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();

  static MaintenanceRecord _parseOne(Object? data) =>
      MaintenanceRecord.fromJson(data! as Map<String, dynamic>);

  @override
  Future<ApiResult<List<MaintenanceRecord>>> history(
    Object vehicleId, {
    int page = 1,
    int perPage = 15,
  }) => _api.get<List<MaintenanceRecord>>(
    ApiEndpoints.vehicleMaintenance(vehicleId),
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  @override
  Future<MaintenanceRecord> addRecord(
    Object vehicleId, {
    required String type,
    required DateTime performedAt,
    String? description,
    int? mileage,
    double? cost,
    String? receiptPath,
  }) async {
    final form = FormData.fromMap({
      'type': type,
      'performed_at': _dateOnly(performedAt),
      'description': ?description,
      'mileage': ?mileage,
      'cost': ?cost,
      if (receiptPath != null)
        'receipt': await MultipartFile.fromFile(receiptPath),
    });
    final result = await _api.post<MaintenanceRecord>(
      ApiEndpoints.vehicleMaintenance(vehicleId),
      body: form,
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<List<int>> exportPdf(Object vehicleId) async {
    final response = await _dio.get<List<int>>(
      ApiEndpoints.vehicleMaintenanceExport(vehicleId),
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  static String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;
}
