part of 'bookings_bloc.dart';

sealed class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

class BookingsLoadRequested extends BookingsEvent {
  const BookingsLoadRequested();
}
