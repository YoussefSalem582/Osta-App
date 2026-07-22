import 'package:geocoding/geocoding.dart';
import 'package:osta/core/services/location_service.dart';

/// City / district / street resolved from a map pin.
typedef ResolvedAddress = ({String? city, String? district, String? street});

/// Best-effort reverse geocoding of a dropped map pin to auto-fill address
/// fields; uses the on-device geocoder (no API key/quota) and fails to `null`.
class ReverseGeocoder {
  const ReverseGeocoder();

  Future<ResolvedAddress?> describe(GeoPoint point) async {
    try {
      final marks = await placemarkFromCoordinates(point.lat, point.lng);
      if (marks.isEmpty) return null;
      final p = marks.first;
      return (
        city: _clean(p.locality) ?? _clean(p.administrativeArea),
        district: _clean(p.subLocality) ?? _clean(p.subAdministrativeArea),
        street: _clean(p.thoroughfare) ?? _clean(p.street) ?? _clean(p.name),
      );
    } on Object {
      // Reverse geocoding is a convenience, never a gate — swallow everything.
      return null;
    }
  }

  static String? _clean(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();
}
