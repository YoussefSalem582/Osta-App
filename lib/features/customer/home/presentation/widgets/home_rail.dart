import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// A titled horizontal rail of tiles — the home feed's one section shape.
class HomeRail extends StatelessWidget {
  const HomeRail({required this.title, required this.tiles, super.key});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tiles.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) => tiles[i],
          ),
        ),
      ],
    );
  }
}
