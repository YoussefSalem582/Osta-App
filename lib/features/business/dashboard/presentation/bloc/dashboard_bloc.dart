import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/bookings/data/model/business_booking.dart';
import 'package:osta/features/business/bookings/data/repo/business_booking_repo.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/dashboard/data/repo/dashboard_repo.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Drives the provider board: fetches three feeds concurrently, degrading
/// per-feed (only the counts/revenue snapshot is required); accept/reject
/// silently re-fetch after.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardOrderAccepted>(_onOrderAccepted);
    on<DashboardOrderRejected>(_onOrderRejected);
  }

  /// Max pending orders previewed on the board — the full queue lives on the
  /// Bookings screen.
  static const _previewLimit = 5;

  String? _lastError;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await _fetch(emit);
  }

  /// Fetches all three feeds concurrently and emits a fresh loaded state, or an
  /// error state when the primary snapshot fails. Shared by initial load,
  /// pull-to-refresh, and the post-action silent refresh (no loading flash).
  Future<void> _fetch(Emitter<DashboardState> emit) async {
    final dataF = _safeDashboard();
    final nameF = _safeCenterName();
    final ordersF = _safePendingOrders();
    final data = await dataF;
    final name = await nameF;
    final orders = await ordersF;

    if (data == null) {
      emit(state.copyWith(status: DashboardStatus.error, error: _lastError));
      return;
    }
    emit(
      DashboardState(
        status: DashboardStatus.loaded,
        data: data,
        centerName: name,
        pendingOrders: orders,
      ),
    );
  }

  Future<BusinessDashboard?> _safeDashboard() async {
    try {
      return await DashboardRepo.dashboard();
    } on ApiException catch (e) {
      _lastError = e.message;
      return null;
    } on Object catch (e, s) {
      log('DashboardBloc.dashboard failed', error: e, stackTrace: s);
      _lastError = e.toString();
      return null;
    }
  }

  Future<String?> _safeCenterName() async {
    try {
      final profile = await GetIt.instance<BusinessOnboardingRepository>()
          .fetchProfile();
      final name = profile.tradeName.trim();
      return name.isEmpty ? null : name;
    } on Object {
      // GET /business/profile isn't deployed everywhere (405) and the name is
      // only a header nicety — never fail the board over it.
      return null;
    }
  }

  Future<List<BusinessBooking>> _safePendingOrders() async {
    try {
      final result = await BusinessBookingRepo.list(
        status: 'pending',
        perPage: _previewLimit,
      );
      return result.data;
    } on Object {
      return const [];
    }
  }

  Future<void> _onOrderAccepted(
    DashboardOrderAccepted event,
    Emitter<DashboardState> emit,
  ) => _act(emit, event.id, () => BusinessBookingRepo.accept(event.id));

  Future<void> _onOrderRejected(
    DashboardOrderRejected event,
    Emitter<DashboardState> emit,
  ) => _act(
    emit,
    event.id,
    () => BusinessBookingRepo.reject(event.id, event.reason),
  );

  /// Runs a per-order mutation with that row marked in-flight, then silently
  /// re-fetches so both the preview list and the counts reflect the change.
  Future<void> _act(
    Emitter<DashboardState> emit,
    String id,
    Future<void> Function() action,
  ) async {
    emit(state.copyWith(actingId: id));
    try {
      await action();
    } on ApiException catch (e) {
      emit(state.copyWith(clearActingId: true, actionError: e.message));
      return;
    } on Object catch (e, s) {
      log('DashboardBloc.order action failed', error: e, stackTrace: s);
      emit(state.copyWith(clearActingId: true, actionError: e.toString()));
      return;
    }
    await _fetch(emit);
  }
}
