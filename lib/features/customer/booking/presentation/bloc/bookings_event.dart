part of 'bookings_bloc.dart';

sealed class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the upcoming + past booking lists — fired on create and by
/// retry/refresh.
class BookingsLoadRequested extends BookingsEvent {
  const BookingsLoadRequested();
}
