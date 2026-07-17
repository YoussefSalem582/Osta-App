import 'package:flutter/material.dart';
import 'package:osta/features/customer/home/presentation/home_fixtures.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_rail.dart';
import 'package:osta/features/customer/home/presentation/widgets/product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeRail(
      title: context.l10n.homeFromShop,
      tiles: [
        for (final p in HomeFixtures.products)
          ProductCard(name: p.name, price: p.price),
      ],
    );
  }
}
