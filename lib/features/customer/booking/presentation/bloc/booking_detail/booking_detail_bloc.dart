import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/customer/booking/data/model/booking.dart';
import 'package:osta/features/customer/booking/data/repo/booking_repo.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  BookingDetailBloc(this.bookingId) : super(const BookingDetailInitial()) {
    on<BookingDetailLoadRequested>(_onLoadRequested);
    on<BookingDetailConfirmRequested>(_onConfirmRequested);
    on<BookingDetailRescheduleRequested>(_onRescheduleRequested);
    on<BookingDetailCancelRequested>(_onCancelRequested);
  }

  final Object bookingId;
  Booking? _current;

  Future<void> _onLoadRequested(
    BookingDetailLoadRequested event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(const BookingDetailLoading());
    try {
      _current = await BookingRepo.show(bookingId);
      emit(BookingDetailLoaded(_current!));
    } on ApiException catch (e) {
      emit(BookingDetailError(e.message));
    } on Object catch (e, s) {
      log('BookingDetailBloc.load failed', error: e, stackTrace: s);
      emit(BookingDetailError(e.toString()));
    }
  }

  Future<void> _onConfirmRequested(
    BookingDetailConfirmRequested event,
    Emitter<BookingDetailState> emit,
  ) => _act(() => BookingRepo.confirm(bookingId), emit);

  Future<void> _onRescheduleRequested(
    BookingDetailRescheduleRequested event,
    Emitter<BookingDetailState> emit,
  ) => _act(() => BookingRepo.reschedule(bookingId, event.scheduledAt), emit);

  Future<void> _onCancelRequested(
    BookingDetailCancelRequested event,
    Emitter<BookingDetailState> emit,
  ) => _act(() => BookingRepo.cancel(bookingId, reason: event.reason), emit);

  Future<void> _act(
    Future<Booking> Function() action,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(const BookingDetailActing());
    try {
      _current = await action();
      emit(BookingDetailLoaded(_current!));
    } on ApiException catch (e) {
      emit(BookingDetailActionError(e.message));
      if (_current != null) emit(BookingDetailLoaded(_current!));
    } on Object catch (e, s) {
      log('BookingDetailBloc action failed', error: e, stackTrace: s);
      emit(BookingDetailActionError(e.toString()));
      if (_current != null) emit(BookingDetailLoaded(_current!));
    }
  }
}
