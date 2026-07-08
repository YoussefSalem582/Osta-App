import 'package:flutter/material.dart';
import 'package:osta/features/home/presentation/widgets/product_card.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'من المتجر',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              ProductCard(
                name: 'إطار ميشلان',
                price: '2800 ج',
              ),
              SizedBox(width: 15),
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
