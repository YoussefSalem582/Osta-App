import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/customer/garage/data/repo/garage_repo.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_state.dart';

class GarageCubit extends Cubit<GarageState> {
  GarageCubit() : super(const GarageInitial());

  Future<void> getVehicles() async {
    emit(const GarageLoading());
    try {
      final response = await GarageRepo.getVehicles();
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
    required String plate,
    String? color,
  }) async {
    emit(const GarageAddLoading());
    try {
      await GarageRepo.addVehicle(
        make: make,
        model: model,
        year: year,
        plate: plate,
        color: color,
      );
      emit(const GarageAddSuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.addVehicle', error: e, stackTrace: s);
      emit(GarageAddError(e.toString()));
    }
  }

  Future<void> setPrimary(Object vehicleId) async {
    emit(const GarageSetPrimaryLoading());
    try {
      await GarageRepo.setPrimary(vehicleId);
      emit(const GarageSetPrimarySuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.setPrimary', error: e, stackTrace: s);
      emit(GarageSetPrimaryError(e.toString()));
    }
  }

  Future<void> deleteVehicle(Object vehicleId) async {
    emit(const GarageDeleteLoading());
    try {
      await GarageRepo.deleteVehicle(vehicleId);
      emit(const GarageDeleteSuccess());
    } on Object catch (e, s) {
      log('Error in GarageCubit.deleteVehicle', error: e, stackTrace: s);
      emit(GarageDeleteError(e.toString()));
    }
  }
}
