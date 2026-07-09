import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/presentation/pages/business_services_page.dart';
import 'package:osta/features/shop/presentation/widgets/shop_product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';

/// الصفحة الرابعة: متجري (منتجات المركز في واجهة النشاط التجاري)
class BusinessShopPage extends StatelessWidget {
  const BusinessShopPage({super.key});

  static const path = '/business-shop';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                          l10n.businessShopEyebrow,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.businessShopTitle,
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
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.8,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  ShopProductCard(
                    title: l10n.businessShopItem1Title,
                    price: l10n.businessShopItem1Price,
                    isActive: true,
                    activeText: l10n.businessShopBadgeActive,
                    pausedText: l10n.businessShopBadgePaused,
                  ),
                  ShopProductCard(
                    title: l10n.businessShopItem2Title,
                    price: l10n.businessShopItem2Price,
                    isActive: true,
                    activeText: l10n.businessShopBadgeActive,
                    pausedText: l10n.businessShopBadgePaused,
                  ),
                  ShopProductCard(
                    title: l10n.businessShopItem3Title,
                    price: l10n.businessShopItem3Price,
                    isActive: true,
                    activeText: l10n.businessShopBadgeActive,
                    pausedText: l10n.businessShopBadgePaused,
                  ),
                  ShopProductCard(
                    title: l10n.businessShopItem4Title,
                    price: l10n.businessShopItem4Price,
                    isActive: false,
                    activeText: l10n.businessShopBadgeActive,
                    pausedText: l10n.businessShopBadgePaused,
                  ),
                ],
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
        currentIndex: 3, 
        onChanged: (index) {
          if (index == 1) {
            context.go(BusinessServicesPage.path);
          }
        },
      ),
    );
  }
}

