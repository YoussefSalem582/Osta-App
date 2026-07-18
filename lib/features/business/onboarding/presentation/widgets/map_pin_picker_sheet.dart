import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Full-screen map pin picker for business onboarding Step 1.
///
/// Returns a [GeoPoint] via [Navigator.pop] when the user confirms, or `null`
/// if they dismiss. Centers on the device location when available, otherwise
/// downtown Cairo.
class MapPinPickerSheet extends StatefulWidget {
  const MapPinPickerSheet({this.initial, super.key});

  /// Existing pin (re-open after a previous pick).
  final GeoPoint? initial;

  /// Opens the picker and returns the confirmed pin, or `null` if cancelled.
  static Future<GeoPoint?> show(
    BuildContext context, {
    GeoPoint? initial,
  }) => Navigator.of(context).push<GeoPoint>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => MapPinPickerSheet(initial: initial),
    ),
  );

  @override
  State<MapPinPickerSheet> createState() => _MapPinPickerSheetState();
}

class _MapPinPickerSheetState extends State<MapPinPickerSheet> {
  static const _cairo = LatLng(30.0444, 31.2357);
  static const _zoom = 15.0;

  late LatLng _center;
  var _ready = false;
  String? _denialMessage;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _center = initial == null ? _cairo : LatLng(initial.lat, initial.lng);
    unawaited(_resolveInitial());
  }

  Future<void> _resolveInitial() async {
    if (widget.initial != null) {
      setState(() => _ready = true);
      return;
    }
    try {
      final point = await getIt<LocationService>().currentPosition();
      if (!mounted) return;
      setState(() {
        _center = LatLng(point.lat, point.lng);
        _ready = true;
      });
    } on LocationUnavailable catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _ready = true;
        _denialMessage = switch (e.reason) {
          LocationDenial.serviceDisabled => l10n.mapLocationDisabledBody,
          LocationDenial.permissionDeniedForever => l10n.mapPermissionBody,
          LocationDenial.permissionDenied => l10n.mapPermissionBody,
        };
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _ready = true);
    }
  }

  void _confirm() {
    Navigator.of(
      context,
    ).pop<GeoPoint>((lat: _center.latitude, lng: _center.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(title: l10n.businessOnboardingPinTitle),
      body: !_ready
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                if (_denialMessage != null)
                  Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _denialMessage!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => unawaited(
                              getIt<LocationService>().openSettings(),
                            ),
                            child: Text(l10n.mapPermissionSettings),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: _zoom,
                        ),
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        onCameraMove: (position) => _center = position.target,
                      ),
                      // Fixed center pin — the map moves under it.
                      IgnorePointer(
                        child: Icon(
                          Icons.location_on,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black26),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      label: l10n.businessOnboardingConfirmLocation,
                      onPressed: _confirm,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
