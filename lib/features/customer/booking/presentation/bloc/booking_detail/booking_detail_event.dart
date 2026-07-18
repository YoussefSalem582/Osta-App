part of 'booking_detail_bloc.dart';

sealed class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

class BookingDetailLoadRequested extends BookingDetailEvent {
  const BookingDetailLoadRequested();
}

class BookingDetailConfirmRequested extends BookingDetailEvent {
  const BookingDetailConfirmRequested();
}

class BookingDetailRescheduleRequested extends BookingDetailEvent {
  const BookingDetailRescheduleRequested(this.scheduledAt);

  final DateTime scheduledAt;

  @override
  List<Object?> get props => [scheduledAt];
}

class BookingDetailCancelRequested extends BookingDetailEvent {
  const BookingDetailCancelRequested({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}
