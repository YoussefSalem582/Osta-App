import 'dart:io';

import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/dashed_rect_painter.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Logo upload widget with dashed border and camera button.
///
/// When [imagePath] is set, shows a preview of the chosen file.
class LogoUploadBox extends StatelessWidget {
  const LogoUploadBox({
    this.onTap,
    this.imagePath,
    super.key,
  });

  final VoidCallback? onTap;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final path = imagePath;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: DashedRectPainter(
                color: theme.colorScheme.primary,
                radius: AppRadii.lg,
              ),
              child: path == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: Image.file(
                        File(path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.businessOnboardingLogoTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.businessOnboardingLogoSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
