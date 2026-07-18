import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/models/promotion_model/promotion_item.dart';
import 'package:osta/features/business/services/data/models/services_model/service_item.dart';
import 'package:osta/features/business/services/presentation/widgets/discount_promotion_banner.dart';
import 'package:osta/features/business/services/presentation/widgets/services_empty_state.dart';
import 'package:osta/features/business/services/presentation/widgets/services_list.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class ServicesContent extends StatelessWidget {
  final List<ServiceItem> services;
  final List<PromotionItem> promotions;

  const ServicesContent({
    super.key,
    required this.services,
    required this.promotions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (services.isEmpty) {
      return const ServicesEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServicesList(services: services),
        const SizedBox(height: AppSpacing.md),
        if (promotions.isNotEmpty)
          DiscountPromotionBanner(
            title: promotions.first.title ?? l10n.businessServicesPromoTitle,
            subtitle:
                promotions.first.subtitle ?? l10n.businessServicesPromoSubtitle,
            activeBadgeText: l10n.businessServicesPromoActiveBadge,
          )
        else
          DiscountPromotionBanner(
            title: l10n.businessServicesPromoTitle,
            subtitle: l10n.businessServicesPromoSubtitle,
            activeBadgeText: l10n.businessServicesPromoActiveBadge,
          ),
      ],
    );
  }
}
