import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Fixed-width tile for the nearby-centers rail: thumbnail, title, then
/// whatever [footer] the caller needs (a distance + rating). `CenterCard` is
/// the sole caller — the shop rail reuses the Store screen's `ProductGridCard`
/// instead, so a product reads identically in both places.
class HomeTile extends StatelessWidget {
  const HomeTile({
    required this.title,
    required this.footer,
    this.onTap,
    this.imageUrl,
    this.placeholderIcon = Icons.image_outlined,
    super.key,
  });

  final String title;
  final Widget footer;
  final VoidCallback? onTap;

  /// Remote thumbnail; falls back to a tinted [placeholderIcon] when null/empty
  /// or on load error.
  final String? imageUrl;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 170,
      child: AppCard(
        onTap: onTap,
        color: theme.colorScheme.surfaceContainerLow,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _thumbnail(theme),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            footer,
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(ThemeData theme) {
    final placeholder = Container(
      height: 120,
      alignment: Alignment.center,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        placeholderIcon,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: url == null || url.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}
