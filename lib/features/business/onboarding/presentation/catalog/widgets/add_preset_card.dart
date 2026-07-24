import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Bulk-add shortcut for the presets currently in view; [count] is the
/// filtered-set size so the label matches what's shown.
class AddPresetCard extends StatelessWidget {
  const AddPresetCard({
    required this.onTap,
    required this.count,
    super.key,
  });

  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
      color: theme.colorScheme.primary,
      elevation: AppElevation.medium,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.businessCatalogAddCommonTitle(count),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.businessCatalogAddCommonSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.appColors.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              size: 24,
              color: context.appColors.onAccent,
            ),
          ),
        ],
      ),
    );
  }
}
