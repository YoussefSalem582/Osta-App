import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A product photo with a graceful fallback — products may have no images
/// (there is no upload endpoint yet; `images` is an optional URL list), so an
/// empty or broken URL renders the tinted placeholder box, never a crash.
class ProductImage extends StatelessWidget {
  const ProductImage({required this.url, this.fit = BoxFit.cover, super.key});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 36,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );

    final src = url;
    if (src == null || src.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: src,
      fit: fit,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
