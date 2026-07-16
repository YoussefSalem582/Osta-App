import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Fixed-width tile for the home feed's horizontal rails: thumbnail, title,
/// then whatever [footer] the caller needs (a price, a distance + rating).
///
/// `CenterCard` and `ProductCard` were byte-identical above the footer, so the
/// chassis lives here once. (Named in prose, not doc links — they import this,
/// so a link would make the import circular.)
class HomeTile extends StatelessWidget {
  const HomeTile({required this.title, required this.footer, super.key});

  final String title;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 170,
      child: AppCard(
        color: theme.colorScheme.surfaceContainerLow,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            // ponytail: placeholder thumbnail — the feed has no image source
            // until #51 wires real repos.
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            footer,
          ],
        ),
      ),
    );
  }
}
