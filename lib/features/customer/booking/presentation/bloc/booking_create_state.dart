part of 'booking_create_bloc.dart';

enum AvailabilityStatus { loading, loaded, error }

/// Rich single-object state for the booking-create flow: which services are
/// picked, which day, the fetched slots for that day, the chosen slot, and the
/// in-flight submit. One object keeps the interacting fields consistent.
class BookingCreateState extends Equatable {
  const BookingCreateState({
    required this.date,
    this.selectedServiceIds = const {},
    this.availabilityStatus = AvailabilityStatus.loading,
    this.slots = const [],
    this.selectedSlot,
    this.submitting = false,
    this.availabilityError,
    this.createdBooking,
    this.submitFailed = false,
  });

  final DateTime date;
  final Set<String> selectedServiceIds;
  final AvailabilityStatus availabilityStatus;
  final List<AvailabilitySlot> slots;
  final AvailabilitySlot? selectedSlot;
  final bool submitting;
  final String? availabilityError;

  /// One-shot: set when `POST /bookings` succeeds so the view can navigate to
  /// the live status screen. Reset on every other emit.
  final Booking? createdBooking;

  /// One-shot: flips when the submit fails so the view can toast. Reset on
  /// every other emit.
  final bool submitFailed;

  bool get canSubmit =>
      selectedServiceIds.isNotEmpty && selectedSlot != null && !submitting;

  BookingCreateState copyWith({
    DateTime? date,
    Set<String>? selectedServiceIds,
    AvailabilityStatus? availabilityStatus,
    List<AvailabilitySlot>? slots,
    AvailabilitySlot? selectedSlot,
    bool clearSelectedSlot = false,
    bool? submitting,
    String? availabilityError,
    Booking? createdBooking,
    bool submitFailed = false,
  }) => BookingCreateState(
    date: date ?? this.date,
    selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
    availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    slots: slots ?? this.slots,
    selectedSlot: clearSelectedSlot
        ? null
        : (selectedSlot ?? this.selectedSlot),
    submitting: submitting ?? this.submitting,
    availabilityError: availabilityError,
    createdBooking: createdBooking,
    submitFailed: submitFailed,
  );

  @override
  List<Object?> get props => [
    date,
    selectedServiceIds,
    availabilityStatus,
    slots,
    selectedSlot,
    submitting,
    availabilityError,
    createdBooking,
    submitFailed,
  ];
}
