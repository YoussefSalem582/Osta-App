import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/bookings/data/model/business_booking.dart';
import 'package:osta/features/business/bookings/data/repo/business_booking_repo.dart';

part 'business_bookings_event.dart';
part 'business_bookings_state.dart';

/// Drives the provider booking queue (`GET /business/bookings`) plus the B2B
/// transitions: accept, reject, advance status, assign a roster mechanic. Each
/// action reloads the list so the active status filter stays correct (a booking
/// that leaves the filtered status drops out).
class BusinessBookingsBloc
    extends Bloc<BusinessBookingsEvent, BusinessBookingsState> {
  BusinessBookingsBloc() : super(const BusinessBookingsState()) {
    on<BusinessBookingsLoadRequested>(_onLoadRequested);
    on<BusinessBookingsFilterChanged>(_onFilterChanged);
    on<BusinessBookingsAcceptRequested>(_onAcceptRequested);
    on<BusinessBookingsRejectRequested>(_onRejectRequested);
    on<BusinessBookingsAdvanceRequested>(_onAdvanceRequested);
    on<BusinessBookingsAssignRequested>(_onAssignRequested);
  }

  Future<void> _onLoadRequested(
    BusinessBookingsLoadRequested event,
    Emitter<BusinessBookingsState> emit,
  ) => _load(emit);

  Future<void> _onFilterChanged(
    BusinessBookingsFilterChanged event,
    Emitter<BusinessBookingsState> emit,
  ) async {
    if (event.status == state.statusFilter) return;
    emit(
      state.copyWith(
        statusFilter: event.status,
        clearStatusFilter: event.status == null,
      ),
    );
    await _load(emit);
  }

  Future<void> _onAcceptRequested(
    BusinessBookingsAcceptRequested event,
    Emitter<BusinessBookingsState> emit,
  ) => _act(() => BusinessBookingRepo.accept(event.id), emit);

  Future<void> _onRejectRequested(
    BusinessBookingsRejectRequested event,
    Emitter<BusinessBookingsState> emit,
  ) => _act(() => BusinessBookingRepo.reject(event.id, event.reason), emit);

  Future<void> _onAdvanceRequested(
    BusinessBookingsAdvanceRequested event,
    Emitter<BusinessBookingsState> emit,
  ) => _act(
    () => BusinessBookingRepo.updateStatus(event.id, event.status),
    emit,
  );

  Future<void> _onAssignRequested(
    BusinessBookingsAssignRequested event,
    Emitter<BusinessBookingsState> emit,
  ) => _act(
    () => BusinessBookingRepo.assignRosterMechanic(event.id, event.mechanicId),
    emit,
  );

  Future<void> _load(Emitter<BusinessBookingsState> emit) async {
    emit(state.copyWith(status: BusinessBookingsStatus.loading));
    try {
      final result = await BusinessBookingRepo.list(
        status: state.statusFilter,
        perPage: 50,
      );
      emit(
        state.copyWith(
          status: BusinessBookingsStatus.loaded,
          bookings: result.data,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: BusinessBookingsStatus.error, error: e.message),
      );
    } on Object catch (e, s) {
      log('BusinessBookingsBloc.load failed', error: e, stackTrace: s);
      emit(
        state.copyWith(
          status: BusinessBookingsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// Runs an action under the `acting` overlay, then reloads. On failure the
  /// error message lands in `actionError` (a one-shot the view toasts), on
  /// success no error surfaces.
  Future<void> _act(
    Future<void> Function() action,
    Emitter<BusinessBookingsState> emit,
  ) async {
    emit(state.copyWith(acting: true));
    try {
      await action();
      await _load(emit);
      emit(state.copyWith(acting: false));
    } on ApiException catch (e) {
      emit(state.copyWith(acting: false, actionError: e.message));
    } on Object catch (e, s) {
      log('BusinessBookingsBloc action failed', error: e, stackTrace: s);
      emit(state.copyWith(acting: false, actionError: e.toString()));
    }
  }
}
