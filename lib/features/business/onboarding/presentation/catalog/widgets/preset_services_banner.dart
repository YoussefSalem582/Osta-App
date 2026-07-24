import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Informational banner for preset services catalog step.
class PresetServicesBanner extends StatelessWidget {
  const PresetServicesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.businessCatalogBannerText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(
            Icons.build_circle_outlined,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
