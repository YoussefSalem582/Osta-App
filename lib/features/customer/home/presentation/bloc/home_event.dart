part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or refresh) the whole feed. Fired once at page creation and again by
/// pull-to-refresh — both run the same four concurrent fetches.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}
