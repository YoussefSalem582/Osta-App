part of 'dashboard_bloc.dart';

enum DashboardStatus { loading, loaded, error }

/// Board state. [data] (counts + revenue) is the primary content — its load
/// failing is what flips [status] to `error`. [centerName] and [pendingOrders]
/// are best-effort enhancements that degrade to null / empty without failing
/// the whole board. [actingId] is the id of the order whose accept/reject is
/// in flight (disables just that row's buttons); [actionError] is a one-shot
/// message the view toasts then the next emit clears.
class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.data,
    this.centerName,
    this.pendingOrders = const [],
    this.error,
    this.actingId,
    this.actionError,
  });

  final DashboardStatus status;
  final BusinessDashboard? data;
  final String? centerName;
  final List<BusinessBooking> pendingOrders;
  final String? error;
  final String? actingId;
  final String? actionError;

  DashboardState copyWith({
    DashboardStatus? status,
    BusinessDashboard? data,
    String? centerName,
    List<BusinessBooking>? pendingOrders,
    String? error,
    String? actingId,
    bool clearActingId = false,
    String? actionError,
  }) => DashboardState(
    status: status ?? this.status,
    data: data ?? this.data,
    centerName: centerName ?? this.centerName,
    pendingOrders: pendingOrders ?? this.pendingOrders,
    error: error,
    actingId: clearActingId ? null : (actingId ?? this.actingId),
    actionError: actionError,
  );

  @override
  List<Object?> get props => [
    status,
    data,
    centerName,
    pendingOrders,
    error,
    actingId,
    actionError,
  ];
}
