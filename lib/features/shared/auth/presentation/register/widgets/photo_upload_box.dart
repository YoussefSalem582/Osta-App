import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Circular profile-photo picker for the register form — dashed ring, person
/// glyph, and camera badge. Mirrors the business onboarding `LogoUploadBox`
/// pattern but uses a round avatar layout.
class PhotoUploadBox extends StatelessWidget {
  const PhotoUploadBox({
    required this.onTap,
    this.imagePath,
    super.key,
  });

  final VoidCallback onTap;

  /// Local file path of the chosen photo; `null` shows the empty prompt state.
  final String? imagePath;

  static const double _ring = 120;
  static const double _badge = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final path = imagePath;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox.square(
            dimension: _ring,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (path == null) ...[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.06),
                    ),
                  ),
                  CustomPaint(
                    size: const Size.square(_ring),
                    painter: _DashedRingPainter(primary),
                  ),
                  Icon(Icons.person_outline, size: 48, color: primary),
                ] else
                  ClipOval(
                    child: Image.file(
                      File(path),
                      width: _ring,
                      height: _ring,
                      fit: BoxFit.cover,
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: _badge,
                    height: _badge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authAddPhoto,
          style: theme.textTheme.titleMedium?.copyWith(
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Draws the dashed circle for [PhotoUploadBox].
class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dashes = 34;
    const sweep = 2 * math.pi / dashes;
    final rect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - 1,
    );
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
