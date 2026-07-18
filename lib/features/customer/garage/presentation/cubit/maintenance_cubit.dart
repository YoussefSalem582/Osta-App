import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/customer/garage/data/repo/maintenance_repo.dart';
import 'package:osta/features/customer/garage/presentation/cubit/maintenance_state.dart';

/// One instance per vehicle, unlike `GarageCubit` which takes the vehicle id
/// per-method.
class MaintenanceCubit extends Cubit<MaintenanceState> {
  MaintenanceCubit(this.vehicleId) : super(const MaintenanceInitial());

  final Object vehicleId;

  Future<void> loadHistory({int page = 1, int perPage = 15}) async {
    emit(const MaintenanceLoading());
    try {
      final result = await MaintenanceRepo.history(
        vehicleId,
        page: page,
        perPage: perPage,
      );
      emit(MaintenanceSuccess(result.data, result.meta));
    } on Object catch (e, s) {
      log('Error in MaintenanceCubit.loadHistory', error: e, stackTrace: s);
      emit(MaintenanceError(e.toString()));
    }
  }

  Future<void> addRecord({
    required String type,
    required DateTime performedAt,
    String? description,
    int? mileage,
    double? cost,
  }) async {
    emit(const MaintenanceAddLoading());
    try {
      await MaintenanceRepo.addRecord(
        vehicleId,
        type: type,
        performedAt: performedAt,
        description: description,
        mileage: mileage,
        cost: cost,
      );
      emit(const MaintenanceAddSuccess());
    } on Object catch (e, s) {
      log('Error in MaintenanceCubit.addRecord', error: e, stackTrace: s);
      emit(MaintenanceAddError(e.toString()));
    }
  }
}
