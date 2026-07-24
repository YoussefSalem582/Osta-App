import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/presentation/map/bloc/map_bloc.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Horizontal category quick-filters sitting under the search bar. Tapping the
/// selected chip clears the filter.
class MapCategoryChips extends StatelessWidget {
  const MapCategoryChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final MapCategory? selected;
  final ValueChanged<MapCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: MapCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = MapCategory.values[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(_label(context, category)),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
            backgroundColor: scheme.surface,
            selectedColor: scheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? scheme.onPrimary : scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: isSelected ? scheme.primary : scheme.outline,
            ),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }

  String _label(BuildContext context, MapCategory category) =>
      switch (category) {
        MapCategory.oil => context.l10n.mapCategoryOil,
        MapCategory.brakes => context.l10n.mapCategoryBrakes,
        MapCategory.ac => context.l10n.mapCategoryAc,
        MapCategory.tires => context.l10n.mapCategoryTires,
      };
}
