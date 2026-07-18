import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_detail.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_pill.dart';

/// At-a-glance block under the hero: the center logo, its rating, location and
/// a type pill. Renders nothing when the center has none of those.
class CenterOverviewCard extends StatelessWidget {
  const CenterOverviewCard({required this.detail, super.key});

  final CenterDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location = [
      detail.district,
      detail.city,
    ].where((s) => s != null && s.isNotEmpty).join('، ');
    final type = _titleCase(detail.centerType);
    final hasLogo = detail.logoUrl != null && detail.logoUrl!.isNotEmpty;

    if (detail.rating == null && location.isEmpty && type == null && !hasLogo) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Logo(url: detail.logoUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.rating != null)
                  _RatingLine(
                    rating: detail.rating!,
                    label: l10n.centerDetailRatingCount(detail.ratingCount),
                  ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _LocationLine(text: location),
                ],
                if (type != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppPill(
                    label: type,
                    background: AppColors.brandGreen.withValues(alpha: 0.12),
                    foreground: AppColors.brandGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// `car_wash` → `Car Wash`; null/blank drops the pill.
  static String? _titleCase(String raw) {
    if (raw.isEmpty) return null;
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLogo = url != null && url!.isNotEmpty;
    return CircleAvatar(
      radius: 26,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundImage: hasLogo ? CachedNetworkImageProvider(url!) : null,
      child: hasLogo
          ? null
          : Icon(
              Icons.storefront_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
    );
  }
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.rating, required this.label});

  final double rating;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 18, color: context.appColors.warning),
        const SizedBox(width: AppSpacing.xs),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
