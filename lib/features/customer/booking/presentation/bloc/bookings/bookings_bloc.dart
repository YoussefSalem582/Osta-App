import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/customer/booking/data/model/booking.dart';
import 'package:osta/features/customer/booking/data/repo/booking_repo.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc() : super(const BookingsInitial()) {
    on<BookingsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    BookingsLoadRequested event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsLoading());
    try {
      final results = await Future.wait([
        BookingRepo.list(status: 'upcoming', perPage: 50),
        BookingRepo.list(status: 'past', perPage: 50),
      ]);
      emit(BookingsLoaded(upcoming: results[0].data, past: results[1].data));
    } on ApiException catch (e) {
      emit(BookingsError(e.message));
    } on Object catch (e, s) {
      log('BookingsBloc.load failed', error: e, stackTrace: s);
      emit(BookingsError(e.toString()));
    }
  }
}
