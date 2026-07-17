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
    final position = await Geolocator.getCurrentPosition();
    return (lat: position.latitude, lng: position.longitude);
  }

  @override
  Future<bool> openSettings() => Geolocator.openAppSettings();
}
