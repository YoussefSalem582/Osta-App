import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/customer/booking/data/models/booking.dart';
import 'package:osta/features/customer/booking/domain/booking_repository.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  BookingDetailBloc(this._repo, this.bookingId)
    : super(const BookingDetailInitial()) {
    on<BookingDetailLoadRequested>(_onLoadRequested);
    on<BookingDetailConfirmRequested>(_onConfirmRequested);
    on<BookingDetailRescheduleRequested>(_onRescheduleRequested);
    on<BookingDetailCancelRequested>(_onCancelRequested);
  }

  final BookingRepository _repo;

  final Object bookingId;
  Booking? _current;

  Future<void> _onLoadRequested(
    BookingDetailLoadRequested event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(const BookingDetailLoading());
    try {
      _current = await _repo.show(bookingId);
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
  ) => _act(() => _repo.confirm(bookingId), emit);

  Future<void> _onRescheduleRequested(
    BookingDetailRescheduleRequested event,
    Emitter<BookingDetailState> emit,
  ) => _act(() => _repo.reschedule(bookingId, event.scheduledAt), emit);

  Future<void> _onCancelRequested(
    BookingDetailCancelRequested event,
    Emitter<BookingDetailState> emit,
  ) => _act(() => _repo.cancel(bookingId, reason: event.reason), emit);

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
