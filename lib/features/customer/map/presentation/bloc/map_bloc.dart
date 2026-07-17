import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/customer/map/data/repo/centers_repo.dart';

part 'map_event.dart';
part 'map_state.dart';

/// Owns the map surface: GPS fix, marker set, search text and category chip.
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._repo, this._location) : super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<SearchChanged>(_onSearchChanged);
    on<CategorySelected>(_onCategorySelected);
    on<RetryRequested>(_onRetryRequested);
  }

  final CentersRepository _repo;
  final LocationService _location;

  /// Keystrokes must not each fire a request.
  static const searchDebounce = Duration(milliseconds: 350);

  /// Only the newest _load() may emit. Chips and search fire concurrent
  /// requests, and the earlier one can land last — without this, a stale
  /// response overwrites fresh centers and the lit chip stops matching the map.
  int _loadGeneration = 0;

  /// Bumped on every keystroke so a debounce that finishes waiting after a
  /// newer one started knows to drop itself instead of firing a request.
  int _searchGeneration = 0;

  Future<bool> openLocationSettings() => _location.openSettings();

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(
      state.copyWith(status: MapStatus.locating, denial: null, error: null),
    );
    try {
      final position = await _location.currentPosition();
      emit(state.copyWith(position: position));
      await _load(emit);
    } on LocationUnavailable catch (e) {
      emit(state.copyWith(status: MapStatus.locationDenied, denial: e.reason));
    } on Object catch (e, s) {
      log('Error in MapBloc.start', error: e, stackTrace: s);
      emit(state.copyWith(status: MapStatus.error, error: e));
    }
  }

  Future<void> _onSearchChanged(
    SearchChanged event,
    Emitter<MapState> emit,
  ) async {
    final generation = ++_searchGeneration;
    emit(state.copyWith(query: event.value));
    await Future<void>.delayed(searchDebounce);
    // A newer keystroke replaced this one while it waited out the debounce.
    if (generation != _searchGeneration) return;
    await _load(emit);
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        category: event.category == state.category ? null : event.category,
      ),
    );
    await _load(emit);
  }

  Future<void> _onRetryRequested(
    RetryRequested event,
    Emitter<MapState> emit,
  ) => state.position == null
      ? _onStarted(const MapStarted(), emit)
      : _load(emit);

  Future<void> _load(Emitter<MapState> emit) async {
    final position = state.position;
    // No fix yet: _onStarted owns that path and will call back in.
    if (position == null) return;
    final generation = ++_loadGeneration;
    emit(state.copyWith(status: MapStatus.loading, error: null));
    try {
      final query = state.query.trim();
      final centers = query.isEmpty
          ? await _repo.nearby(
              lat: position.lat,
              lng: position.lng,
              category: state.category?.slug,
            )
          : await _repo.search(query: query, category: state.category?.slug);
      if (generation != _loadGeneration) return;
      emit(state.copyWith(status: MapStatus.ready, centers: centers));
    } on Object catch (e, s) {
      log('Error in MapBloc._load', error: e, stackTrace: s);
      if (generation != _loadGeneration) return;
      emit(state.copyWith(status: MapStatus.error, error: e));
    }
  }
}
