import 'package:flutter/material.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/services/reverse_geocoder.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/map_pin_picker_sheet.dart';

/// Map-pin picking + reverse-geocode autofill shared by screens embedding
/// `LocationPickerCard`; implementers own their own location storage and
/// controllers.
mixin BusinessLocationPickerMixin<T extends StatefulWidget> on State<T> {
  /// Current pin, if any — seeds the picker sheet re-opened on an existing
  /// pick.
  GeoPoint? get pickerLocation;

  TextEditingController get cityController;
  TextEditingController get addressController;

  /// `null` on screens with no district field (business identity step).
  TextEditingController? get districtController => null;

  /// Persist the confirmed pin and clear any location validation error.
  void onLocationPicked(GeoPoint point);

  Future<void> pickLocation() async {
    final point = await MapPinPickerSheet.show(
      context,
      initial: pickerLocation,
    );
    if (point == null || !mounted) return;
    onLocationPicked(point);
    await autofillFromPin(point);
  }

  /// Reverse-geocode the pin and fill any address field left blank — never
  /// overwrite typed text. Best-effort: a null result changes nothing.
  Future<void> autofillFromPin(GeoPoint point) async {
    final a = await const ReverseGeocoder().describe(point);
    if (a == null || !mounted) return;
    setState(() {
      if (cityController.text.trim().isEmpty && a.city != null) {
        cityController.text = a.city!;
      }
      final district = districtController;
      if (district != null &&
          district.text.trim().isEmpty &&
          a.district != null) {
        district.text = a.district!;
      }
      if (addressController.text.trim().isEmpty && a.street != null) {
        addressController.text = a.street!;
      }
    });
  }
}
