import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/dashboard/data/repo/dashboard_repo.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Loads the provider dashboard snapshot (`GET /business/dashboard`) — today /
/// pending / completed counts + revenue for the caller's center.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      emit(DashboardLoaded(await DashboardRepo.dashboard()));
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    } on Object catch (e, s) {
      log('DashboardBloc.load failed', error: e, stackTrace: s);
      emit(DashboardError(e.toString()));
    }
  }
}
