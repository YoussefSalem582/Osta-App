import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/customer/booking/data/model/booking.dart';
import 'package:osta/features/customer/booking/data/repo/booking_repo.dart';
import 'package:osta/features/customer/map/data/model/center_detail.dart';
import 'package:osta/features/customer/map/data/repo/center_detail_repo.dart';

part 'booking_create_event.dart';
part 'booking_create_state.dart';

/// Drives the booking-create flow for one center: pick services, pick a day
/// (loads that day's slots via `GET /centers/{id}/availability`), pick a slot,
/// then `POST /bookings`.
class BookingCreateBloc extends Bloc<BookingCreateEvent, BookingCreateState> {
  BookingCreateBloc(this.centerId) : super(BookingCreateState(date: _today())) {
    on<BookingCreateStarted>(_onStarted);
    on<BookingCreateServiceToggled>(_onServiceToggled);
    on<BookingCreateDateSelected>(_onDateSelected);
    on<BookingCreateSlotSelected>(_onSlotSelected);
    on<BookingCreateSubmitted>(_onSubmitted);
  }

  final Object centerId;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> _onStarted(
    BookingCreateStarted event,
    Emitter<BookingCreateState> emit,
  ) => _load(emit);

  void _onServiceToggled(
    BookingCreateServiceToggled event,
    Emitter<BookingCreateState> emit,
  ) {
    final next = Set<String>.of(state.selectedServiceIds);
    if (!next.remove(event.id)) next.add(event.id);
    emit(state.copyWith(selectedServiceIds: next));
  }

  Future<void> _onDateSelected(
    BookingCreateDateSelected event,
    Emitter<BookingCreateState> emit,
  ) async {
    final date = event.date;
    final day = DateTime(date.year, date.month, date.day);
    if (day == state.date) return;
    emit(state.copyWith(date: day, clearSelectedSlot: true));
    await _load(emit);
  }

  void _onSlotSelected(
    BookingCreateSlotSelected event,
    Emitter<BookingCreateState> emit,
  ) => emit(state.copyWith(selectedSlot: event.slot));

  Future<void> _load(Emitter<BookingCreateState> emit) async {
    emit(
      state.copyWith(
        availabilityStatus: AvailabilityStatus.loading,
        slots: const [],
      ),
    );
    try {
      final d = state.date;
      final date = '${d.year}-${_two(d.month)}-${_two(d.day)}';
      final availability = await CenterDetailRepo.availability(
        centerId,
        date: date,
      );
      emit(
        state.copyWith(
          availabilityStatus: AvailabilityStatus.loaded,
          slots: availability.slots,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          availabilityStatus: AvailabilityStatus.error,
          availabilityError: e.message,
        ),
      );
    } on Object catch (e, s) {
      log(
        'BookingCreateBloc._load failed',
        error: e,
        stackTrace: s,
      );
      emit(
        state.copyWith(
          availabilityStatus: AvailabilityStatus.error,
          availabilityError: e.toString(),
        ),
      );
    }
  }

  /// Creates the booking. On success the created [Booking] lands in
  /// [BookingCreateState.createdBooking] (the view navigates to its live
  /// status); on failure [BookingCreateState.submitFailed] flips (the view
  /// toasts).
  Future<void> _onSubmitted(
    BookingCreateSubmitted event,
    Emitter<BookingCreateState> emit,
  ) async {
    final slot = state.selectedSlot;
    if (slot?.start == null || state.selectedServiceIds.isEmpty) return;
    emit(state.copyWith(submitting: true));
    try {
      final booking = await BookingRepo.create(
        serviceCenterId: centerId.toString(),
        scheduledAt: slot!.start!,
        serviceIds: state.selectedServiceIds.toList(),
      );
      emit(state.copyWith(submitting: false, createdBooking: booking));
    } on Object catch (e, s) {
      log('BookingCreateBloc._onSubmitted failed', error: e, stackTrace: s);
      emit(state.copyWith(submitting: false, submitFailed: true));
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
