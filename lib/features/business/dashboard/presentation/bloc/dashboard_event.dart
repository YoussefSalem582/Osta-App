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
