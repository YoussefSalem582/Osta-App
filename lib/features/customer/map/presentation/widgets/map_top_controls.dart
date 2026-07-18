import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/presentation/bloc/map_bloc.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_category_chips.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_filter_button.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';

/// Search field + filter button + category chips floated over the map.
class MapTopControls extends StatelessWidget {
  const MapTopControls({
    required this.searchController,
    required this.onSearchChanged,
    required this.filterActive,
    required this.onFilterTap,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool filterActive;
  final VoidCallback onFilterTap;
  final MapCategory? selectedCategory;
  final ValueChanged<MapCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: AppTextField(
                    controller: searchController,
                    label: context.l10n.mapSearchHint,
                    prefixIcon: Icons.search,
                    textInputAction: TextInputAction.search,
                    onChanged: onSearchChanged,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MapFilterButton(active: filterActive, onTap: onFilterTap),
            ],
          ),
        ),
        MapCategoryChips(
          selected: selectedCategory,
          onSelected: onCategorySelected,
        ),
      ],
    ),
  );
}
