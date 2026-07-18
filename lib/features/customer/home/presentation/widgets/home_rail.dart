import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// A titled horizontal rail of tiles — the home feed's one section shape.
class HomeRail extends StatelessWidget {
  const HomeRail({
    required this.title,
    required this.tiles,
    this.onSeeAll,
    this.empty,
    super.key,
  });

  final String title;
  final List<Widget> tiles;

  /// Optional trailing "See all" affordance in the section header. Hidden when
  /// the rail is empty (nothing to see).
  final VoidCallback? onSeeAll;

  /// Shown in place of the rail when [tiles] is empty (a "no data" card).
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = tiles.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onSeeAll != null && !isEmpty)
              TextButton(
                onPressed: onSeeAll,
                child: Text(context.l10n.seeAll),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isEmpty)
          empty ?? const SizedBox.shrink()
        else
          // Content-sized (no fixed height) so a tile is never clipped — the
          // row grows to the tallest tile. Tiles are fixed-width, so a plain
          // horizontal scroll suffices (rails hold at most a handful).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  tiles[i],
                ],
              ],
            ),
          ),
      ],
    );
  }
}
