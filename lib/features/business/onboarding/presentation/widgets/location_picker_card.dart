import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Location picker card. Shows a live map preview centered on the picked pin,
/// or a grid placeholder before one is set.
///
/// The card carries its own state: the border and label go primary once a pin
/// is set ([hasLocation]), or error-colored when [hasError] and still unset —
/// so the required-location message lives on the control instead of floating
/// beneath it.
class LocationPickerCard extends StatelessWidget {
  const LocationPickerCard({
    this.onTap,
    this.latitude,
    this.longitude,
    this.hasLocation = false,
    this.hasError = false,
    super.key,
  });

  final VoidCallback? onTap;
  final double? latitude;
  final double? longitude;
  final bool hasLocation;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final showError = hasError && !hasLocation;
    final accent = showError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final showMap = hasLocation && latitude != null && longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          onTap: onTap,
          padding: EdgeInsets.zero,
          elevation: AppElevation.none,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.6,
          ),
          border: hasLocation || showError
              ? BorderSide(color: accent, width: 2)
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: SizedBox(
              height: 180,
              child: Stack(
                children: [
                  if (showMap)
                    _MapPreview(target: LatLng(latitude!, longitude!))
                  else ...[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: accent,
                      ),
                    ),
                  ],
                  PositionedDirectional(
                    bottom: AppSpacing.md,
                    start: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 16, color: accent),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            hasLocation
                                ? l10n.businessOnboardingLocationSelected
                                : l10n.businessOnboardingSelectLocation,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showError) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.businessOnboardingLocationRequired,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Non-interactive map thumbnail with a fixed pin over the picked point.
///
/// Gestures are disabled and a transparent catcher sits on top so the whole
/// card still opens the full-screen picker on tap instead of panning here.
class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.target});
  final LatLng target;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: target, zoom: 15),
            markers: {
              Marker(markerId: const MarkerId('picked'), position: target),
            },
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            myLocationButtonEnabled: false,
            liteModeEnabled: true,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 24.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
