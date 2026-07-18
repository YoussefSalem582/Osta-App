import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/presentation/widgets/shop_product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class ShopContent extends StatelessWidget {
  final List<Datum> products;
  final void Function(Datum) onEditTap;
  final void Function(Datum) onMoreTap;

  const ShopContent({
    super.key,
    required this.products,
    required this.onEditTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: .8,
      ),
      itemBuilder: (_, index) {
        final product = products[index];

        return ShopProductCard(
          title: product.name ?? '',
          price: '${product.price ?? 0} ج',
          isActive: product.status == 'active',
          activeText: l10n.businessShopBadgeActive,
          pausedText: l10n.businessShopBadgePaused,
          onTap: () => onEditTap(product),
          onMoreTap: () => onMoreTap(product),
        );
      },
    );
  }
}
