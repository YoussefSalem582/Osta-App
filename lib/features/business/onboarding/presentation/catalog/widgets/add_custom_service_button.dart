import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/dashed_rect_painter.dart';
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
        painter: DashedRectPainter(
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
