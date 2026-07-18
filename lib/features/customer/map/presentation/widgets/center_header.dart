import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_detail.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Cover image, rating, and location for a service center's detail page.
class CenterHeader extends StatelessWidget {
  const CenterHeader({required this.detail, super.key});

  final CenterDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final location = [
      detail.district,
      detail.city,
    ].where((s) => s != null && s.isNotEmpty).join('، ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.coverUrl != null && detail.coverUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: CachedNetworkImage(
              imageUrl: detail.coverUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            if (detail.rating != null) ...[
              Icon(
                Icons.star_rounded,
                size: 18,
                color: context.appColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                detail.rating!.toStringAsFixed(1),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' · ${l10n.centerDetailRatingCount(detail.ratingCount)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        if (location.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
