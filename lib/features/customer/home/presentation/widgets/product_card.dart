import 'package:flutter/material.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_tile.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.name, required this.price, super.key});

  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HomeTile(
      title: name,
      footer: Text(
        price,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
