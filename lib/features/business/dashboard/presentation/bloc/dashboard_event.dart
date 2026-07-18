part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch the dashboard snapshot — fired on first paint and pull-to-refresh.
class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

/// Accept a pending order (`pending → confirmed`) straight from the board.
class DashboardOrderAccepted extends DashboardEvent {
  const DashboardOrderAccepted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Reject a pending order (`pending → cancelled`) with a required [reason].
class DashboardOrderRejected extends DashboardEvent {
  const DashboardOrderRejected(this.id, this.reason);

  final String id;
  final String reason;

  @override
  List<Object?> get props => [id, reason];
}
