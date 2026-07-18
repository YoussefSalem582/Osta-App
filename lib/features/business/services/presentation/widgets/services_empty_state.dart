import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';
import 'package:osta/features/business/services/presentation/widgets/discount_promotion_banner.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class ServicesEmptyState extends StatefulWidget {
  const ServicesEmptyState({super.key});

  @override
  State<ServicesEmptyState> createState() => _ServicesEmptyStateState();
}

class _ServicesEmptyStateState extends State<ServicesEmptyState> {
  bool _oilSelected = true;
  bool _brakesSelected = true;
  bool _acSelected = true;
  bool _electricSelected = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServiceToggleCard(
          title: l10n.businessServicesOilTitle,
          subtitle: l10n.businessServicesOilSubtitle,
          price: l10n.businessServicesOilPrice,
          isSelected: _oilSelected,
          onChanged: (val) => setState(() => _oilSelected = val),
        ),
        const SizedBox(height: AppSpacing.sm),
        ServiceToggleCard(
          title: l10n.businessServicesBrakesTitle,
          subtitle: l10n.businessServicesBrakesSubtitle,
          price: l10n.businessServicesBrakesPrice,
          isSelected: _brakesSelected,
          onChanged: (val) => setState(() => _brakesSelected = val),
        ),
        const SizedBox(height: AppSpacing.sm),
        ServiceToggleCard(
          title: l10n.businessServicesAcTitle,
          subtitle: l10n.businessServicesAcSubtitle,
          price: l10n.businessServicesAcPrice,
          isSelected: _acSelected,
          onChanged: (val) => setState(() => _acSelected = val),
        ),
        const SizedBox(height: AppSpacing.sm),
        ServiceToggleCard(
          title: l10n.businessServicesElectricTitle,
          subtitle: l10n.businessServicesElectricSubtitle,
          price: l10n.businessServicesElectricPrice,
          isSelected: _electricSelected,
          onChanged: (val) => setState(() => _electricSelected = val),
        ),
        const SizedBox(height: AppSpacing.md),
        DiscountPromotionBanner(
          title: l10n.businessServicesPromoTitle,
          subtitle: l10n.businessServicesPromoSubtitle,
          activeBadgeText: l10n.businessServicesPromoActiveBadge,
        ),
      ],
    );
  }
}
