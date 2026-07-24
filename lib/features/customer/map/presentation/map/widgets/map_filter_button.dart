import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';

/// Filter entry in the search row. A dot marks a non-default filter (the
/// "nearby only" switch turned off) so the user sees they're viewing all
/// centers without opening the sheet.
class MapFilterButton extends StatelessWidget {
  const MapFilterButton({required this.active, required this.onTap, super.key});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: IconButton(
      tooltip: context.l10n.mapFilters,
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: active,
        smallSize: 8,
        backgroundColor: AppColors.brandGreen,
        child: const Icon(Icons.tune),
      ),
    ),
  );
}
