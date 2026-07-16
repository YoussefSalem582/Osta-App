import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_tile.dart';

class CenterCard extends StatelessWidget {
  const CenterCard({
    required this.distance,
    required this.name,
    required this.rate,
    super.key,
  });
  final String name;
  final String distance;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HomeTile(
      title: name,
      footer: Row(
        children: [
          Expanded(
            child: Text(
              distance,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$rate ⭐',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
