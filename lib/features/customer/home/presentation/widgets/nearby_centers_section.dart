import 'package:flutter/material.dart';
import 'package:osta/features/customer/home/presentation/widgets/center_card.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_rail.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class NearbyCentersSection extends StatelessWidget {
  const NearbyCentersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeRail(
      title: context.l10n.homeNearbyCenters,
      tiles: const [
        CenterCard(name: 'ورشة الأمانة', distance: '2 KM', rate: 4.6),
        CenterCard(name: 'مركز النصر', distance: '1.2 KM', rate: 4.8),
      ],
    );
  }
}
