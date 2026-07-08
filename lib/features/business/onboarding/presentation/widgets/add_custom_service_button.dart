import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Dashed button CTA to add a custom catalog service.
class AddCustomServiceButton extends StatelessWidget {
  const AddCustomServiceButton({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          radius: AppRadii.lg,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          alignment: Alignment.center,
          child: Text(
            l10n.businessCatalogAddCustomService,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        const length = 6.0;
        const gap = 4.0;
        canvas.drawPath(
          metric.extractPath(distance, distance + length),
          paint,
        );
        distance += length + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
