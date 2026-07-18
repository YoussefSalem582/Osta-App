import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_detail.dart';

/// Collapsing hero for the center detail page: the cover photo (or a brand
/// gradient when there's none) behind a legibility scrim, with the center name
/// pinned to the bottom so it survives the collapse into the app-bar title.
class CenterHero extends StatelessWidget {
  const CenterHero({required this.detail, super.key});

  final CenterDetail detail;

  static const _expandedHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final hasCover = detail.coverUrl != null && detail.coverUrl!.isNotEmpty;
    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      // The back button and title sit over the dark scrim, so force white.
      foregroundColor: Colors.white,
      backgroundColor: AppColors.brandGreen,
      flexibleSpace: FlexibleSpaceBar(
        // `start: xl + lg` keeps the collapsed title clear of the back button.
        titlePadding: const EdgeInsetsDirectional.only(
          start: AppSpacing.xl + AppSpacing.lg,
          end: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        title: Text(
          detail.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCover)
              CachedNetworkImage(
                imageUrl: detail.coverUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const _BrandBackdrop(),
                placeholder: (_, _) => const _BrandBackdrop(),
              )
            else
              const _BrandBackdrop(),
            // Scrim: darkens the lower half so white text stays legible over
            // any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand-green gradient shown when a center has no cover photo.
class _BrandBackdrop extends StatelessWidget {
  const _BrandBackdrop();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.brandGreen, Color(0xFF06331A)],
      ),
    ),
  );
}
