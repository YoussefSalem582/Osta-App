import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// A resolved GPS fix. A record rather than a new class, matching the
/// `TokenPair` typedef in `core/network/dio_client.dart`.
typedef GeoPoint = ({double lat, double lng});

/// Why a position could not be resolved — each maps to its own map UI.
enum LocationDenial {
  /// User said no; asking again is allowed.
  permissionDenied,

  /// User said never; only the OS settings screen can undo it.
  permissionDeniedForever,

  /// Location services are off device-wide.
  serviceDisabled,
}

class LocationUnavailable implements Exception {
  const LocationUnavailable(this.reason);

  final LocationDenial reason;

  @override
  String toString() => 'LocationUnavailable: $reason';
}

/// Seam over `geolocator`'s statics so the cubit's permission branches are
/// unit-testable without platform channels.
abstract class LocationService {
  Future<GeoPoint> currentPosition();

  /// Opens the OS app-settings page (the only exit from "denied forever").
  Future<bool> openSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<GeoPoint> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailable(LocationDenial.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationUnavailable(LocationDenial.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationUnavailable(LocationDenial.permissionDenied);
    }
    try {
      // Without a limit getCurrentPosition waits forever for a fix — on
      // emulators and cold GPS that never lands, so the map's "locating"
      // spinner hangs and the camera never leaves the fallback target.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
      return (lat: position.latitude, lng: position.longitude);
    } on TimeoutException {
      // Fresh fix timed out — use the last cached one so the map still centers
      // instead of spinning. If none either, let it surface as an error.
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) rethrow;
      return (lat: last.latitude, lng: last.longitude);
    }
  }

  @override
  Future<bool> openSettings() => Geolocator.openAppSettings();
}
