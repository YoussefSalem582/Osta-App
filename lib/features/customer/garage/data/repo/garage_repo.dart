import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/garage/data/model/garage_response/datum.dart';
import 'package:osta/features/customer/garage/data/model/garage_response/garage_response.dart';

class GarageRepo {
  static Future<GarageResponse?> getVehicles() async {
    try {
      final api = GetIt.instance<ApiClient>();
      final result = await api.get<List<Datum>>(
        ApiEndpoints.vehicles,
        parse: (data) => (data! as List<dynamic>)
            .map((e) => Datum.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return GarageResponse(success: true, data: result.data);
    } on Object catch (e, s) {
      log('Error in GarageRepo.getVehicles', error: e, stackTrace: s);
      return null;
    }
  }

  /// Keys must match `StoreVehicleRequest` exactly. Every optional rule there
  /// is `nullable`, so a misspelt key is not a 422 — it is a silent drop that
  /// still returns 201. `plate` was sent here and discarded on every save.
  static Future<void> addVehicle({
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    int? currentMileage,
    String? color,
  }) async {
    final api = GetIt.instance<ApiClient>();
    await api.post<void>(
      ApiEndpoints.vehicles,
      body: {
        'make': make,
        'model': model,
        'year': year,
        'plate_number': plateNumber,
        'current_mileage': ?currentMileage,
        if (color != null && color.isNotEmpty) 'color': color,
      },
      parse: (_) {},
    );
  }

  static Future<void> setPrimary(Object vehicleId) async {
    final api = GetIt.instance<ApiClient>();
    await api.post<void>(
      ApiEndpoints.vehiclePrimary(vehicleId),
      parse: (_) {},
    );
  }

  static Future<void> deleteVehicle(Object vehicleId) async {
    final api = GetIt.instance<ApiClient>();
    await api.delete<void>(
      ApiEndpoints.vehicle(vehicleId),
      parse: (_) {},
    );
  }
}
