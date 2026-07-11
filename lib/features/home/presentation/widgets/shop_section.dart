import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/home/presentation/widgets/product_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeFromShop,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              ProductCard(
                name: 'إطار ميشلان',
                price: '2800 ج',
              ),
              SizedBox(width: AppSpacing.md),
              ProductCard(
                name: 'زيت موبيل',
                price: '250 ج',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
