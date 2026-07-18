import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_pill.dart';

/// A catalog service row with a price.
///
/// Two modes:
/// - **Toggle** (presets): pass [onChanged]; the whole card and a trailing
///   [Switch] flip [isSelected].
/// - **Removable** (custom services): pass [onRemove]; the row is always in the
///   catalog and carries a "Custom" badge plus a delete button. There is no
///   switch, because a custom service isn't selected — it's staged, and the
///   only action is to drop it. (A switch that deleted on "off" was the old
///   data-loss trap this replaces.)
class ServiceToggleCard extends StatelessWidget {
  const ServiceToggleCard({
    required this.title,
    required this.subtitle,
    required this.price,
    this.isSelected = false,
    this.onChanged,
    this.onRemove,
    super.key,
  }) : assert(
         (onChanged == null) != (onRemove == null),
         'Provide exactly one of onChanged (toggle) or onRemove (removable).',
       );

  final String title;
  final String subtitle;
  final String price;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onRemove;

  bool get _removable => onRemove != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Removable (custom) rows always read as "in"; presets follow selection.
    final active = _removable || isSelected;

    return AppCard(
      onTap: _removable ? null : () => onChanged!(!isSelected),
      elevation: AppElevation.low,
      border: BorderSide(
        color: active
            ? theme.colorScheme.primary.withValues(alpha: 0.3)
            : theme.colorScheme.outlineVariant,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (_removable) ...[
                      const SizedBox(width: AppSpacing.sm),
                      AppPill(
                        label: l10n.businessCatalogCustomBadge,
                        background: theme.colorScheme.primaryContainer,
                        foreground: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                price,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (_removable)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                  tooltip: l10n.businessCatalogRemoveService,
                )
              else
                Switch.adaptive(
                  value: isSelected,
                  onChanged: onChanged,
                  thumbColor: WidgetStateProperty.all(
                    theme.colorScheme.onPrimary,
                  ),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
