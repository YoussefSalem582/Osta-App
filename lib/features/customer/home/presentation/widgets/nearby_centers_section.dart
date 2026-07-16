import 'package:flutter/material.dart';
import 'package:osta/features/customer/home/presentation/home_fixtures.dart';
import 'package:osta/features/customer/home/presentation/widgets/center_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_rail.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class NearbyCentersSection extends StatelessWidget {
  const NearbyCentersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeRail(
      title: context.l10n.homeNearbyCenters,
      tiles: [
        for (final c in HomeFixtures.centers)
          CenterCard(name: c.name, distance: c.distance, rate: c.rate),
      ],
    );
  }
}
