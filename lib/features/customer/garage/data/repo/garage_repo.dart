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

  static Future<void> addVehicle({
    required String make,
    required String model,
    required int year,
    required String plate,
    String? color,
  }) async {
    final api = GetIt.instance<ApiClient>();
    await api.post<void>(
      ApiEndpoints.vehicles,
      body: {
        'make': make,
        'model': model,
        'year': year,
        'plate': plate,
        'color': color ?? '',
      },
      parse: (_) {},
    );
  }
}
