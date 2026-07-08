import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Informational banner indicating roles can be changed later.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
