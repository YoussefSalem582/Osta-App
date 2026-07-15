import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/formatters/app_formatters.dart';
import 'package:osta/shared/ui/app_button.dart';

/// Bottom dialog shown when a map marker is tapped.
Future<void> showPlaceDialog(
  BuildContext context, {
  required CenterSummary center,
  required VoidCallback onBook,
  required VoidCallback onDetails,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) =>
      PlaceDialog(center: center, onBook: onBook, onDetails: onDetails),
);

/// Center summary + the two actions the epic calls for.
class PlaceDialog extends StatelessWidget {
  const PlaceDialog({
    required this.center,
    required this.onBook,
    required this.onDetails,
    super.key,
  });

  final CenterSummary center;
  final VoidCallback onBook;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(imageUrl: center.imageUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetaRow(center: center),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(label: l10n.mapBook, onPressed: onBook),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: l10n.mapDetails,
                    onPressed: onDetails,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rating · distance · open-now, each dropped when the API omits it.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.center});

  final CenterSummary center;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final rating = center.rating;
    final distanceKm = center.distanceKm;
    final isOpenNow = center.isOpenNow;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (rating != null) ...[
          Icon(Icons.star_rounded, size: 16, color: context.appColors.warning),
          Text(
            NumberFormatter.decimal(rating, locale: locale),
            style: theme.textTheme.labelLarge,
          ),
        ],
        if (distanceKm != null)
          Text(
            l10n.mapDistanceKm(
              // One decimal is all the dialog has room for.
              NumberFormatter.decimal(
                (distanceKm * 10).round() / 10,
                locale: locale,
              ),
            ),
            style: theme.textTheme.bodySmall,
          ),
        if (isOpenNow != null)
          Text(
            isOpenNow ? l10n.mapOpenNow : l10n.mapClosed,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isOpenNow ? context.appColors.success : theme.hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageUrl});

  static const _size = 64.0;

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.brandGreen.withValues(alpha: 0.12),
      child: const Icon(Icons.store_mall_directory_outlined),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: SizedBox.square(
        dimension: _size,
        child: imageUrl == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => placeholder,
                errorWidget: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
