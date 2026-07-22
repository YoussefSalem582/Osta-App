part of 'map_bloc.dart';

/// Category quick-filter chips above the map. [slug] is the `category` query
/// param — align these with the backend enum once it is published.
enum MapCategory {
  oil('oil'),
  brakes('brakes'),
  ac('ac'),
  tires('tires');

  const MapCategory(this.slug);

  final String slug;
}

enum MapStatus {
  initial,

  /// Waiting on the GPS fix / permission prompt.
  locating,

  /// Have a position, fetching centers.
  loading,

  /// Centers resolved (possibly zero — see [MapState.isEmpty]).
  ready,
  error,

  /// No position: permission refused or location services off.
  locationDenied,
}

/// Single state class (not class-per-state): the map's fields change together
/// and every status needs to keep the others.
class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.position,
    this.centers = const [],
    this.query = '',
    this.category,
    this.nearbyOnly = true,
    this.denial,
    this.error,
  });

  final MapStatus status;
  final GeoPoint? position;
  final List<CenterSummary> centers;
  final String query;
  final MapCategory? category;

  /// When true (default), discovery is the radius-bounded `/centers/nearby`.
  /// Toggled off in the filter sheet, an empty search falls through to
  /// `/centers/search` with no `q` — every active center, distance be damned.
  final bool nearbyOnly;

  /// Set only when [status] is [MapStatus.locationDenied].
  final LocationDenial? denial;

  /// The caught exception, kept raw so the widget can localize by type.
  final Object? error;

  /// A search/filter that legitimately matched nothing.
  bool get isEmpty => status == MapStatus.ready && centers.isEmpty;

  /// First paint and every refresh that has nothing to show yet.
  bool get isBusy =>
      status == MapStatus.locating ||
      (status == MapStatus.loading && centers.isEmpty);

  MapState copyWith({
    MapStatus? status,
    GeoPoint? position,
    List<CenterSummary>? centers,
    String? query,
    Object? category = _unset,
    bool? nearbyOnly,
    Object? denial = _unset,
    Object? error = _unset,
  }) => MapState(
    status: status ?? this.status,
    position: position ?? this.position,
    centers: centers ?? this.centers,
    query: query ?? this.query,
    category: category == _unset ? this.category : category as MapCategory?,
    nearbyOnly: nearbyOnly ?? this.nearbyOnly,
    denial: denial == _unset ? this.denial : denial as LocationDenial?,
    error: error == _unset ? this.error : error,
  );

  /// Sentinel so `copyWith(category: null)` clears instead of meaning "keep".
  static const _unset = Object();

  @override
  List<Object?> get props => [
    status,
    position,
    centers,
    query,
    category,
    nearbyOnly,
    denial,
    error,
  ];
}
