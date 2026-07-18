part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load / reload the feed. Fired on first paint, error retry and
/// pull-to-refresh.
class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

/// Marks one notification read and swaps it in place (tapping an unread tile).
class NotificationsMarkReadRequested extends NotificationsEvent {
  const NotificationsMarkReadRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Marks every currently-unread row read (the app-bar action).
class NotificationsMarkAllReadRequested extends NotificationsEvent {
  const NotificationsMarkAllReadRequested();
}
