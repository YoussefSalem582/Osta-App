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
    required String plateNumber,
    int? currentMileage,
    String? color,
  }) async {
    emit(const GarageAddLoading());
    try {
      await GarageRepo.addVehicle(
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
}
