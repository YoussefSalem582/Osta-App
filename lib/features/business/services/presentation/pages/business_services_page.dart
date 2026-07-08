import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';
import 'package:osta/features/business/services/presentation/widgets/discount_promotion_banner.dart';
import 'package:osta/features/business/services/presentation/widgets/services_filter_toggle.dart';
import 'package:osta/features/shop/presentation/pages/business_shop_page.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';

/// الصفحة الأولى: الكتالوج والأسعار (الخدمات والعروض في واجهة النشاط التجاري)
class BusinessServicesPage extends StatefulWidget {
  const BusinessServicesPage({super.key});

  static const path = '/business-services';

  @override
  State<BusinessServicesPage> createState() => _BusinessServicesPageState();
}

class _BusinessServicesPageState extends State<BusinessServicesPage> {
  int _selectedTab = 0; // 0: الخدمات, 1: العروض
  bool _oilSelected = true;
  bool _brakesSelected = true;
  bool _acSelected = true;
  bool _electricSelected = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header bar exactly matching Image 1
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.businessServicesEyebrow,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.businessServicesTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ServicesFilterToggle(
                      selectedTab: _selectedTab,
                      onTabChanged: (val) => setState(() => _selectedTab = val),
                      servicesLabel: l10n.businessServicesTabServices,
                      offersLabel: l10n.businessServicesTabOffers,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_selectedTab == 0) ...[
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
                    ] else ...[
                      DiscountPromotionBanner(
                        title: l10n.businessServicesPromoTitle,
                        subtitle: l10n.businessServicesPromoSubtitle,
                        activeBadgeText: l10n.businessServicesPromoActiveBadge,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF111827),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        items: [
          AppBottomNavItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view_rounded,
            label: l10n.shellNavDashboard,
          ),
          AppBottomNavItem(
            icon: Icons.local_offer_outlined,
            selectedIcon: Icons.sell,
            label: l10n.shellNavCatalog,
          ),
          AppBottomNavItem(
            icon: Icons.calendar_today_outlined,
            selectedIcon: Icons.calendar_today,
            label: l10n.shellNavCalendar,
          ),
          AppBottomNavItem(
            icon: Icons.shopping_bag_outlined,
            selectedIcon: Icons.shopping_bag,
            label: l10n.shellNavStore,
          ),
          AppBottomNavItem(
            icon: Icons.more_horiz,
            selectedIcon: Icons.more_horiz,
            label: l10n.shellNavMore,
          ),
        ],
        currentIndex: 1, // الكتالوج
        onChanged: (index) {
          if (index == 3) {
            context.go(BusinessShopPage.path);
          }
        },
      ),
    );
  }
}
