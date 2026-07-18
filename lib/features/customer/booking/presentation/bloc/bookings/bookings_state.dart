part of 'bookings_bloc.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

class BookingsLoaded extends BookingsState {
  const BookingsLoaded({required this.upcoming, required this.past});

  final List<Booking> upcoming;
  final List<Booking> past;

  @override
  List<Object?> get props => [upcoming, past];
}

class BookingsError extends BookingsState {
  const BookingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
