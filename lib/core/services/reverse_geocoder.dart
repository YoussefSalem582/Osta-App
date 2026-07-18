import 'package:geocoding/geocoding.dart';
import 'package:osta/core/services/location_service.dart';

/// City / district / street resolved from a map pin.
typedef ResolvedAddress = ({String? city, String? district, String? street});

/// Best-effort reverse geocoding of a dropped map pin, so address forms can
/// auto-fill city / district / street instead of making the owner type them.
///
/// Uses the on-device geocoder (iOS `CLGeocoder`, Android `Geocoder`) — no API
/// key, no quota. Any failure (offline, no match, platform gap) resolves to
/// `null`; the form just stays manual, exactly as before.
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
