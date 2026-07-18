import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Compact "no data" placeholder for a Home feed section — an icon, a line of
/// copy, and an optional action (e.g. "Enable location"). Keeps a section
/// present and explained instead of silently dropping out of the feed.
class HomeEmptyCard extends StatelessWidget {
  const HomeEmptyCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showAction = actionLabel != null && onAction != null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (showAction) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: actionLabel!,
              variant: AppButtonVariant.secondary,
              icon: Icons.my_location,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
