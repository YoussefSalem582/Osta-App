import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/formatters/app_formatters.dart';

/// Bottom-sheet list of the centers currently on the map. It shows whatever
/// `MapState.centers` holds, so it already respects the search box and the
/// "nearby only" filter — toggle that off to list every center. Tapping a row
/// opens that center's profile (same destination as a marker tap).
Future<void> showCentersListSheet(
  BuildContext context, {
  required List<CenterSummary> centers,
  required ValueChanged<CenterSummary> onCenterTap,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) =>
      _CentersListSheet(centers: centers, onCenterTap: onCenterTap),
);

class _CentersListSheet extends StatelessWidget {
  const _CentersListSheet({required this.centers, required this.onCenterTap});

  final List<CenterSummary> centers;
  final ValueChanged<CenterSummary> onCenterTap;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              context.l10n.mapCentersCount(centers.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              itemCount: centers.length,
              itemBuilder: (context, i) => _CenterRow(
                center: centers[i],
                onTap: () => onCenterTap(centers[i]),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CenterRow extends StatelessWidget {
  const _CenterRow({required this.center, required this.onTap});

  final CenterSummary center;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final rating = center.rating;
    final distanceKm = center.distanceKm;
    final isOpenNow = center.isOpenNow;

    return ListTile(
      onTap: onTap,
      leading: _Thumbnail(imageUrl: center.imageUrl),
      title: Text(
        center.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Wrap(
        spacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (rating != null) ...[
            Icon(
              Icons.star_rounded,
              size: 14,
              color: context.appColors.warning,
            ),
            Text(NumberFormatter.decimal(rating, locale: locale)),
          ],
          if (distanceKm != null)
            Text(
              l10n.mapDistanceKm(
                NumberFormatter.decimal(
                  (distanceKm * 10).round() / 10,
                  locale: locale,
                ),
              ),
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
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageUrl});

  static const _size = 48.0;

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
