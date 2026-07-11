import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/presentation/widgets/shop_product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// متجري (منتجات المركز) — the Store tab body of the business shell.
/// Scaffold-less: the shell owns the app bar and bottom nav.
class BusinessShopPage extends StatelessWidget {
  const BusinessShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
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
                    const SizedBox(height: AppSpacing.xs),
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
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onPrimary,
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
    );
  }
}
