part of 'booking_detail_bloc.dart';

abstract class BookingDetailState extends Equatable {
  const BookingDetailState();

  @override
  List<Object?> get props => [];
}

class BookingDetailInitial extends BookingDetailState {
  const BookingDetailInitial();
}

class BookingDetailLoading extends BookingDetailState {
  const BookingDetailLoading();
}

class BookingDetailLoaded extends BookingDetailState {
  const BookingDetailLoaded(this.booking);

  final Booking booking;

  @override
  List<Object?> get props => [booking];
}

class BookingDetailError extends BookingDetailState {
  const BookingDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class BookingDetailActing extends BookingDetailState {
  const BookingDetailActing();
}

class BookingDetailActionError extends BookingDetailState {
  const BookingDetailActionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
