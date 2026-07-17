import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Horizontal category filter. `null` selection is the leading "All" chip.
/// [categories] are stable keys; [labelOf] resolves each to a localized label.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    super.key,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String Function(String key) labelOf;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: l10n.shopCategoryAll,
              selected: selected == null,
              onTap: () => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return _Chip(
            label: labelOf(category),
            selected: selected == category,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: selected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: BorderSide(
            color: selected
                ? Colors.transparent
                : theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
