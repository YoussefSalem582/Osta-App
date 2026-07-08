import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/role/presentation/widgets/coming_soon.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Card representing a selectable or coming-soon user role.
class RoleCard extends StatelessWidget {
  const RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.enabled = true,
    this.badgeLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final border = enabled
        ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
        : null;
    final backgroundColor = enabled
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerLow;

    final iconBgColor = enabled
        ? theme.colorScheme.primaryContainer.withValues(alpha:0.4)
        : theme.colorScheme.surfaceContainerHighest;
    final iconColor = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return AppCard(
      onTap: enabled ? onTap : null,
      border: border,
      color: backgroundColor,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: enabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (!enabled && badgeLabel != null)
            ComingSoonBadge(label: badgeLabel!)
          else if (enabled)
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
