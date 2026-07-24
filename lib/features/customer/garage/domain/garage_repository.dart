import 'package:osta/features/customer/garage/data/models/garage_response/datum.dart';
import 'package:osta/features/customer/garage/data/models/garage_response/garage_response.dart';

/// Contract for the customer's vehicle garage (`/vehicles`).
abstract interface class GarageRepository {
  /// Returns null on any error (the cubit maps null to an error state).
  Future<GarageResponse?> getVehicles();

  Future<void> addVehicle({
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    int? currentMileage,
    String? color,
  });

  /// Single-vehicle detail. Returns null on any error, like [getVehicles].
  Future<Datum?> getVehicle(Object vehicleId);

  Future<void> updateVehicle({
    required Object vehicleId,
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    int? currentMileage,
    String? color,
  });

  Future<void> setPrimary(Object vehicleId);

  Future<void> deleteVehicle(Object vehicleId);
}
