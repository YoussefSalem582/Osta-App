part of 'booking_create_bloc.dart';

sealed class BookingCreateEvent extends Equatable {
  const BookingCreateEvent();

  @override
  List<Object?> get props => [];
}

class BookingCreateStarted extends BookingCreateEvent {
  const BookingCreateStarted();
}

class BookingCreateServiceToggled extends BookingCreateEvent {
  const BookingCreateServiceToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class BookingCreateDateSelected extends BookingCreateEvent {
  const BookingCreateDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class BookingCreateSlotSelected extends BookingCreateEvent {
  const BookingCreateSlotSelected(this.slot);

  final AvailabilitySlot slot;

  @override
  List<Object?> get props => [slot];
}

class BookingCreateSubmitted extends BookingCreateEvent {
  const BookingCreateSubmitted();
}
