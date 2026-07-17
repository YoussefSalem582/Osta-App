import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/customer/map/data/repo/centers_repo.dart';
import 'package:osta/features/customer/map/presentation/bloc/map_bloc.dart';

const _center = CenterSummary(
  id: '1',
  name: 'Nasr Center',
  latitude: 30.05,
  longitude: 31.33,
);

/// Records the calls the bloc makes so the tests can assert which endpoint
/// ran and with which filter.
class _FakeCentersRepository implements CentersRepository {
  _FakeCentersRepository({this.result = const [_center], this.error});

  final List<CenterSummary> result;
  final Exception? error;

  int nearbyCalls = 0;
  int searchCalls = 0;
  String? lastCategory;
  String? lastQuery;

  @override
  Future<List<CenterSummary>> nearby({
    required double lat,
    required double lng,
    String? category,
  }) async {
    nearbyCalls++;
    lastCategory = category;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<List<CenterSummary>> search({
    required String query,
    String? category,
  }) async {
    searchCalls++;
    lastQuery = query;
    lastCategory = category;
    if (error != null) throw error!;
    return result;
  }
}

/// Hands out a Completer per call so a test can land responses out of order.
class _GatedCentersRepository implements CentersRepository {
  final pending = <Completer<List<CenterSummary>>>[];

  @override
  Future<List<CenterSummary>> nearby({
    required double lat,
    required double lng,
    String? category,
  }) {
    final completer = Completer<List<CenterSummary>>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<List<CenterSummary>> search({
    required String query,
    String? category,
  }) {
    final completer = Completer<List<CenterSummary>>();
    pending.add(completer);
    return completer.future;
  }
}

class _FakeLocationService implements LocationService {
  _FakeLocationService({this.error, this.gate});

  static const GeoPoint point = (lat: 30.0, lng: 31.0);

  final Exception? error;

  /// When set, the fix only lands once the test completes it.
  final Completer<void>? gate;

  bool settingsOpened = false;

  @override
  Future<GeoPoint> currentPosition() async {
    if (gate != null) await gate!.future;
    if (error != null) throw error!;
    return point;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened = true;
    return true;
  }
}

/// `bloc.add()` doesn't return a completion future the way the old cubit's
/// methods did, so tests wait on the state stream instead. Callers that need
/// to observe a round-trip through an unchanged status (e.g. ready -> ready)
/// must bracket it with an intermediate status instead of waiting on the
/// final one directly, or this resolves immediately against the old state.
extension _WaitFor on MapBloc {
  Future<void> waitUntil(bool Function(MapState) predicate) async {
    if (predicate(state)) return;
    await stream.firstWhere(predicate);
  }
}

void main() {
  group('MapBloc.start', () {
    test('resolves a position then loads nearby centers', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status != MapStatus.initial && !s.isBusy);

      expect(bloc.state.status, MapStatus.ready);
      expect(bloc.state.position, (lat: 30.0, lng: 31.0));
      expect(bloc.state.centers, [_center]);
      expect(repo.nearbyCalls, 1);
      expect(repo.searchCalls, 0);
    });

    test('reports empty rather than error when nothing is nearby', () async {
      final bloc = MapBloc(
        _FakeCentersRepository(result: const []),
        _FakeLocationService(),
      );
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      expect(bloc.state.isEmpty, isTrue);
    });

    // The acceptance criterion: a refused permission is a state, not a crash.
    test('surfaces a denied permission without throwing', () async {
      final bloc = MapBloc(
        _FakeCentersRepository(),
        _FakeLocationService(
          error: const LocationUnavailable(LocationDenial.permissionDenied),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.locationDenied);

      expect(bloc.state.denial, LocationDenial.permissionDenied);
    });

    test('distinguishes denied-forever so the UI can offer settings', () async {
      final bloc = MapBloc(
        _FakeCentersRepository(),
        _FakeLocationService(
          error: const LocationUnavailable(
            LocationDenial.permissionDeniedForever,
          ),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.locationDenied);

      expect(bloc.state.denial, LocationDenial.permissionDeniedForever);
    });

    test('distinguishes location services being off', () async {
      final bloc = MapBloc(
        _FakeCentersRepository(),
        _FakeLocationService(
          error: const LocationUnavailable(LocationDenial.serviceDisabled),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.locationDenied);

      expect(bloc.state.denial, LocationDenial.serviceDisabled);
    });

    test('keeps the raw ApiException so the widget can localize it', () async {
      final bloc = MapBloc(
        _FakeCentersRepository(error: const NetworkException()),
        _FakeLocationService(),
      );
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.error);

      expect(bloc.state.error, isA<NetworkException>());
    });
  });

  group('MapBloc.searchChanged', () {
    test('debounces keystrokes into a single search call', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      bloc
        ..add(const SearchChanged('o'))
        ..add(const SearchChanged('oi'))
        ..add(const SearchChanged('oil'));

      // Query is visible immediately; the request waits for the debounce.
      await bloc.waitUntil((s) => s.query == 'oil');
      expect(repo.searchCalls, 0);

      await Future<void>.delayed(
        MapBloc.searchDebounce + const Duration(milliseconds: 50),
      );

      expect(repo.searchCalls, 1);
      expect(repo.lastQuery, 'oil');
    });

    test('an emptied search box falls back to nearby', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      bloc.add(const SearchChanged('   '));
      await Future<void>.delayed(
        MapBloc.searchDebounce + const Duration(milliseconds: 50),
      );

      expect(repo.searchCalls, 0);
      expect(repo.nearbyCalls, 2);
    });
  });

  group('MapBloc.selectCategory', () {
    test('passes the slug as the category filter', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      bloc.add(const CategorySelected(MapCategory.tires));
      await bloc.waitUntil(
        (s) => s.category == MapCategory.tires && s.status == MapStatus.ready,
      );

      expect(bloc.state.category, MapCategory.tires);
      expect(repo.lastCategory, 'tires');
    });

    test('re-tapping the active chip clears the filter', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      bloc.add(const CategorySelected(MapCategory.oil));
      await bloc.waitUntil(
        (s) => s.category == MapCategory.oil && s.status == MapStatus.ready,
      );
      bloc.add(const CategorySelected(MapCategory.oil));
      await bloc.waitUntil(
        (s) => s.category == null && s.status == MapStatus.ready,
      );

      expect(bloc.state.category, isNull);
      expect(repo.lastCategory, isNull);
    });

    test('combines the category with an active search', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      bloc.add(const SearchChanged('nasr'));
      await Future<void>.delayed(
        MapBloc.searchDebounce + const Duration(milliseconds: 50),
      );
      bloc.add(const CategorySelected(MapCategory.brakes));
      await bloc.waitUntil(
        (s) => s.category == MapCategory.brakes && s.status == MapStatus.ready,
      );

      expect(repo.lastQuery, 'nasr');
      expect(repo.lastCategory, 'brakes');
      expect(repo.searchCalls, 2);
    });
  });

  group('MapBloc concurrency', () {
    // A slow earlier request must not overwrite a newer one: the lit chip would
    // stop matching the markers, with nothing to signal the mismatch.
    test('a stale response never overwrites a newer one', () async {
      final repo = _GatedCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);

      bloc.add(const MapStarted());
      // Let the position resolve so the first nearby request registers.
      await Future<void>.delayed(Duration.zero);
      bloc.add(const CategorySelected(MapCategory.oil));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const CategorySelected(MapCategory.brakes));
      await Future<void>.delayed(Duration.zero);

      expect(repo.pending, hasLength(3));

      // Newest lands first; the two stale ones land after and must be dropped.
      repo.pending[2].complete(const [
        CenterSummary(id: 'brakes', name: 'Brakes Place'),
      ]);
      await Future<void>.delayed(Duration.zero);
      repo.pending[1].complete(const [
        CenterSummary(id: 'oil', name: 'Oil Place'),
      ]);
      repo.pending[0].complete(const []);

      await bloc.waitUntil(
        (s) => s.status == MapStatus.ready && s.centers.isNotEmpty,
      );

      expect(bloc.state.category, MapCategory.brakes);
      expect(bloc.state.centers.single.id, 'brakes');
    });

    test('closing mid-request does not throw', () async {
      final gate = Completer<void>();
      final bloc = MapBloc(
        _FakeCentersRepository(),
        _FakeLocationService(gate: gate),
      )..add(const MapStarted());

      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      gate.complete();

      // Bloc silently drops emit() calls from a closed/canceled emitter
      // instead of throwing, so the handler resuming after close() must
      // finish quietly rather than surfacing an uncaught error.
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('MapBloc.retry', () {
    test('re-asks for the position when there is still no fix', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(
        repo,
        _FakeLocationService(
          error: const LocationUnavailable(LocationDenial.permissionDenied),
        ),
      );
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.locationDenied);

      // Bracket with the transient `locating` status: the status before and
      // after retry is identically `locationDenied`, so waiting on it
      // directly would resolve against the pre-retry state.
      bloc.add(const RetryRequested());
      await bloc.waitUntil((s) => s.status == MapStatus.locating);
      await bloc.waitUntil((s) => s.status == MapStatus.locationDenied);

      // Never had a fix, so retry must not try to load centers.
      expect(repo.nearbyCalls, 0);
    });

    test('reloads centers when a fix already exists', () async {
      final repo = _FakeCentersRepository();
      final bloc = MapBloc(repo, _FakeLocationService());
      addTearDown(bloc.close);
      bloc.add(const MapStarted());
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      // Same bracketing as above: ready -> ready needs the transient
      // `loading` in between to avoid resolving against the pre-retry state.
      bloc.add(const RetryRequested());
      await bloc.waitUntil((s) => s.status == MapStatus.loading);
      await bloc.waitUntil((s) => s.status == MapStatus.ready);

      expect(repo.nearbyCalls, 2);
    });
  });
}
