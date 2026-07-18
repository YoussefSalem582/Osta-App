import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/model/promotion.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/formatters/app_formatters.dart';
import 'package:osta/shared/ui/app_card.dart';

/// One promotion: tap to edit, switch to enable/disable, delete to remove.
/// Mirrors `ServiceManagementRow`.
class PromotionRow extends StatelessWidget {
  const PromotionRow({
    required this.promotion,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Promotion promotion;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final discount = promotion.discountType == 'percent'
        ? l10n.promotionDiscountPercentOff(
            NumberFormatter.decimal(promotion.discountValue, locale: locale),
          )
        : l10n.promotionDiscountFixedOff(
            EgpFormatter.format(promotion.discountValue, locale: locale),
          );

    return AppCard(
      onTap: onEdit,
      elevation: AppElevation.low,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  discount,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.promotionRedeemedCount(promotion.redeemedCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: promotion.isActive, onChanged: onToggle),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: theme.colorScheme.error,
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }
}
