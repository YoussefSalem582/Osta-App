import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/garage/data/model/maintenance_record.dart';

/// Data layer over the vehicle maintenance endpoints (backend
/// `Api/B2C/MaintenanceController` + `MaintenanceRecordResource`). Static
/// methods like the sibling `GarageRepo`; errors bubble up as the typed
/// `ApiException`.
///
/// Ownership is server-enforced: a vehicle the caller doesn't own returns 404
/// (indistinguishable from missing) — nothing special to handle here.
abstract final class MaintenanceRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<MaintenanceRecord> _parseList(Object? data) =>
      (data! as List<dynamic>)
          .map((e) => MaintenanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();

  static MaintenanceRecord _parseOne(Object? data) =>
      MaintenanceRecord.fromJson(data! as Map<String, dynamic>);

  /// GET `vehicles/{id}/maintenance` — paginated history, newest first
  /// (fixed server ordering). [perPage] is clamped to [1, 50] server-side.
  /// Returns the whole [ApiResult] so callers keep `.meta`.
  static Future<ApiResult<List<MaintenanceRecord>>> history(
    Object vehicleId, {
    int page = 1,
    int perPage = 15,
  }) => _api.get<List<MaintenanceRecord>>(
    ApiEndpoints.vehicleMaintenance(vehicleId),
    parse: _parseList,
    query: {'page': page, 'per_page': perPage},
  );

  /// POST `vehicles/{id}/maintenance` — add a manual record (201).
  /// Multipart because of the optional [receiptPath] file. [type] must be an
  /// `ExpenseCategory` value; [performedAt] is sent date-only and must be
  /// today-or-earlier server-side. Keys match `StoreMaintenanceRecordRequest`.
  static Future<MaintenanceRecord> addRecord(
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

  /// GET `vehicles/{id}/maintenance/export` — raw PDF bytes (attachment).
  /// ponytail: bypasses [ApiClient] on purpose — its `_send` always parses the
  /// JSON envelope, and this route streams a binary PDF, not JSON. Reuses the
  /// same GetIt-registered authenticated [Dio], so the bearer token is still
  /// attached. Upgrade path: add a `download`/bytes method to ApiClient if
  /// another endpoint needs binary. Raw `DioException` bubbles (not mapped to
  /// `ApiException`) since we skip the envelope client.
  static Future<List<int>> exportPdf(Object vehicleId) async {
    final dio = GetIt.instance<Dio>();
    final response = await dio.get<List<int>>(
      ApiEndpoints.vehicleMaintenanceExport(vehicleId),
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  static String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;
}
