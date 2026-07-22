part of 'business_bookings_bloc.dart';

enum BusinessBookingsStatus { loading, loaded, error }

/// Feed state for the provider's booking queue. `statusFilter` null means
/// the "all" tab; `acting` blocks the UI during an action; `actionError` is
/// a one-shot, cleared on the next emit.
class BusinessBookingsState extends Equatable {
  const BusinessBookingsState({
    this.statusFilter,
    this.status = BusinessBookingsStatus.loading,
    this.bookings = const [],
    this.error,
    this.acting = false,
    this.actionError,
  });

  final String? statusFilter;
  final BusinessBookingsStatus status;
  final List<BusinessBooking> bookings;
  final String? error;
  final bool acting;
  final String? actionError;

  BusinessBookingsState copyWith({
    String? statusFilter,
    bool clearStatusFilter = false,
    BusinessBookingsStatus? status,
    List<BusinessBooking>? bookings,
    String? error,
    bool? acting,
    String? actionError,
  }) => BusinessBookingsState(
    statusFilter: clearStatusFilter
        ? null
        : (statusFilter ?? this.statusFilter),
    status: status ?? this.status,
    bookings: bookings ?? this.bookings,
    error: error,
    acting: acting ?? this.acting,
    actionError: actionError,
  );

  @override
  List<Object?> get props => [
    statusFilter,
    status,
    bookings,
    error,
    acting,
    actionError,
  ];
}
