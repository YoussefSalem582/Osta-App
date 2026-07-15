part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Resolve the user's position, then load the centers around it. Also fired
/// by the retry button when the previous attempt never got a fix.
class MapStarted extends MapEvent {
  const MapStarted();
}

/// Fired on every keystroke — the bloc owns the debounce, not the caller.
class SearchChanged extends MapEvent {
  const SearchChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Tapping the active chip clears it (the chips are a toggle, not a radio).
class CategorySelected extends MapEvent {
  const CategorySelected(this.category);

  final MapCategory category;

  @override
  List<Object?> get props => [category];
}

/// Retry button once a fix already exists — [MapStarted] handles "no fix yet".
class RetryRequested extends MapEvent {
  const RetryRequested();
}
