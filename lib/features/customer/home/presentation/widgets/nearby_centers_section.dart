import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/customer/home/presentation/widgets/center_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_empty_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_rail.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/formatters/app_formatters.dart';

class NearbyCentersSection extends StatelessWidget {
  const NearbyCentersSection({
    required this.centers,
    this.locationDenied = false,
    this.onEnableLocation,
    super.key,
  });

  final List<CenterSummary> centers;
  final bool locationDenied;
  final VoidCallback? onEnableLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return HomeRail(
      title: l10n.homeNearbyCenters,
      // Location off → prompt to enable it; otherwise a plain "none nearby".
      empty: locationDenied
          ? HomeEmptyCard(
              icon: Icons.location_off_outlined,
              message: l10n.homeNearbyEmptyBody,
              actionLabel: l10n.homeEnableLocation,
              onAction: onEnableLocation,
            )
          : HomeEmptyCard(
              icon: Icons.store_mall_directory_outlined,
              message: l10n.homeNoCentersNearby,
            ),
      tiles: [
        for (final c in centers)
          CenterCard(
            name: c.name,
            imageUrl: c.imageUrl,
            distance: c.distanceKm == null
                ? ''
                : l10n.mapDistanceKm(
                    NumberFormatter.decimal(c.distanceKm!, locale: locale),
                  ),
            rate: c.rating ?? 0,
            onTap: c.id.isEmpty
                ? null
                : () => context.push(AppRoutes.centerDetail, extra: c.id),
          ),
      ],
    );
  }
}
