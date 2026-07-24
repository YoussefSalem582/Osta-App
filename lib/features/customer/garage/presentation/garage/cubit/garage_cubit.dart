import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/customer/garage/domain/garage_repository.dart';
import 'package:osta/features/customer/garage/presentation/garage/cubit/garage_state.dart';

class GarageCubit extends Cubit<GarageState> {
  GarageCubit(this._repo) : super(const GarageInitial());

  final GarageRepository _repo;

  Future<void> getVehicles() async {
    emit(const GarageLoading());
    try {
      final response = await _repo.getVehicles();
      if (response != null && response.success == true) {
        emit(GarageSuccess(response));
      } else {
        emit(const GarageError('Failed to load vehicles'));
      }
    } on Object catch (e, s) {
      log('Error in GarageCubit.getVehicles', error: e, stackTrace: s);
      emit(GarageError(e.toString()));
    }
  }

  Future<void> addVehicle({
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    int? currentMileage,
    String? color,
  }) async {
    emit(const GarageAddLoading());
    try {
      await _repo.addVehicle(
        make: make,
        model: model,
        year: year,
        plateNumber: plateNumber,
        currentMileage: currentMileage,
        color: color,
      );
      emit(const GarageAddSuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.addVehicle', error: e, stackTrace: s);
      emit(GarageAddError(e.toString()));
    }
  }

  Future<void> updateVehicle({
    required Object vehicleId,
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    int? currentMileage,
    String? color,
  }) async {
    emit(const GarageUpdateLoading());
    try {
      await _repo.updateVehicle(
        vehicleId: vehicleId,
        make: make,
        model: model,
        year: year,
        plateNumber: plateNumber,
        currentMileage: currentMileage,
        color: color,
      );
      emit(const GarageUpdateSuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.updateVehicle', error: e, stackTrace: s);
      emit(GarageUpdateError(e.toString()));
    }
  }

  Future<void> setPrimary(Object vehicleId) async {
    emit(const GarageSetPrimaryLoading());
    try {
      await _repo.setPrimary(vehicleId);
      emit(const GarageSetPrimarySuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.setPrimary', error: e, stackTrace: s);
      emit(GarageSetPrimaryError(e.toString()));
    }
  }

  Future<void> deleteVehicle(Object vehicleId) async {
    emit(const GarageDeleteLoading());
    try {
      await _repo.deleteVehicle(vehicleId);
      emit(const GarageDeleteSuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.deleteVehicle', error: e, stackTrace: s);
      emit(GarageDeleteError(e.toString()));
    }
  }
}
