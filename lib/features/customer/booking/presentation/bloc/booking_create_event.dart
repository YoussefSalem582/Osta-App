part of 'booking_create_bloc.dart';

sealed class BookingCreateEvent extends Equatable {
  const BookingCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Load the initial day's availability — fired once by the view on create
/// (replaces the cubit's constructor auto-load).
class BookingCreateStarted extends BookingCreateEvent {
  const BookingCreateStarted();
}

/// Toggle a service in/out of the selection.
class BookingCreateServiceToggled extends BookingCreateEvent {
  const BookingCreateServiceToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Pick a day; clears the chosen slot and reloads that day's availability.
class BookingCreateDateSelected extends BookingCreateEvent {
  const BookingCreateDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

/// Pick one of the loaded slots.
class BookingCreateSlotSelected extends BookingCreateEvent {
  const BookingCreateSlotSelected(this.slot);

  final AvailabilitySlot slot;

  @override
  List<Object?> get props => [slot];
}

/// Submit the booking (`POST /bookings`).
class BookingCreateSubmitted extends BookingCreateEvent {
  const BookingCreateSubmitted();
}
