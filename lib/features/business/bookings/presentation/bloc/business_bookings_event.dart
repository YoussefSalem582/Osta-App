part of 'business_bookings_bloc.dart';

sealed class BusinessBookingsEvent extends Equatable {
  const BusinessBookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the queue for the active status filter. Also fired by the
/// error-state retry button and on first paint.
class BusinessBookingsLoadRequested extends BusinessBookingsEvent {
  const BusinessBookingsLoadRequested();
}

/// Switch the status filter chip; null is the "all" tab. Reloads the queue.
class BusinessBookingsFilterChanged extends BusinessBookingsEvent {
  const BusinessBookingsFilterChanged(this.status);

  final String? status;

  @override
  List<Object?> get props => [status];
}

/// Accept a pending booking.
class BusinessBookingsAcceptRequested extends BusinessBookingsEvent {
  const BusinessBookingsAcceptRequested(this.id);

  final Object id;

  @override
  List<Object?> get props => [id];
}

/// Reject a pending booking with the given reason.
class BusinessBookingsRejectRequested extends BusinessBookingsEvent {
  const BusinessBookingsRejectRequested(this.id, this.reason);

  final Object id;
  final String reason;

  @override
  List<Object?> get props => [id, reason];
}

/// Advance a booking to the next `status` (e.g. `in_progress`, `completed`).
class BusinessBookingsAdvanceRequested extends BusinessBookingsEvent {
  const BusinessBookingsAdvanceRequested(this.id, this.status);

  final Object id;
  final String status;

  @override
  List<Object?> get props => [id, status];
}

/// Assign (or clear, when `mechanicId` is null) a roster mechanic on a booking.
class BusinessBookingsAssignRequested extends BusinessBookingsEvent {
  const BusinessBookingsAssignRequested(this.id, this.mechanicId);

  final Object id;
  final String? mechanicId;

  @override
  List<Object?> get props => [id, mechanicId];
}
