part of 'booking_detail_bloc.dart';

sealed class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the booking — fired on create and by retry/refresh.
class BookingDetailLoadRequested extends BookingDetailEvent {
  const BookingDetailLoadRequested();
}

/// Confirm the booking.
class BookingDetailConfirmRequested extends BookingDetailEvent {
  const BookingDetailConfirmRequested();
}

/// Reschedule the booking to [scheduledAt].
class BookingDetailRescheduleRequested extends BookingDetailEvent {
  const BookingDetailRescheduleRequested(this.scheduledAt);

  final DateTime scheduledAt;

  @override
  List<Object?> get props => [scheduledAt];
}

/// Cancel the booking, optionally with a [reason].
class BookingDetailCancelRequested extends BookingDetailEvent {
  const BookingDetailCancelRequested({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}
