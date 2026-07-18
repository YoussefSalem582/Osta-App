import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/models/promotion_model/promotion_item.dart';
import 'package:osta/features/business/services/presentation/widgets/discount_promotion_banner.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class PromotionsContent extends StatelessWidget {
  final List<PromotionItem> promotions;

  const PromotionsContent({
    super.key,
    required this.promotions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (promotions.isEmpty) {
      return DiscountPromotionBanner(
        title: l10n.businessServicesPromoTitle,
        subtitle: l10n.businessServicesPromoSubtitle,
        activeBadgeText: l10n.businessServicesPromoActiveBadge,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final promo in promotions) ...[
          DiscountPromotionBanner(
            title: promo.title ?? l10n.businessServicesPromoTitle,
            subtitle: promo.subtitle ?? l10n.businessServicesPromoSubtitle,
            activeBadgeText: l10n.businessServicesPromoActiveBadge,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
