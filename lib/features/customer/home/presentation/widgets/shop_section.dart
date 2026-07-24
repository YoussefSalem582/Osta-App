import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_empty_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_rail.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/presentation/widgets/product_grid_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Home shop rail. Reuses the Store screen's [ProductGridCard] so a product
/// reads identically in both places — the card needs a bounded box (its image
/// is `Expanded`), so each tile is sized to the Store grid's 0.72 aspect.
class ShopSection extends StatelessWidget {
  const ShopSection({required this.products, super.key});

  final List<Product> products;

  // Store grid uses childAspectRatio 0.72 (w/h); match it so the rail card is
  // the same shape as the grid card.
  static const double _tileWidth = 160;
  static const double _tileHeight = _tileWidth / 0.72;

  @override
  Widget build(BuildContext context) {
    return HomeRail(
      title: context.l10n.homeFromShop,
      onSeeAll: () => context.push(AppRoutes.shopBrowse),
      empty: HomeEmptyCard(
        icon: Icons.shopping_bag_outlined,
        message: context.l10n.homeShopEmpty,
      ),
      tiles: [
        for (final p in products)
          SizedBox(
            width: _tileWidth,
            height: _tileHeight,
            child: ProductGridCard(
              product: p,
              onTap: p.id.isEmpty
                  ? null
                  : () => context.push(AppRoutes.productDetail, extra: p.id),
            ),
          ),
      ],
    );
  }
}
