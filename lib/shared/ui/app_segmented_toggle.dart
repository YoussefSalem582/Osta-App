import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Brand segmented control — a pill track holding animated pill tabs.
///
/// [expand] picks the layout: `false` sizes each tab to its label (a compact
/// inline filter), `true` splits the width evenly (a full-width tab bar).
class AppSegmentedToggle extends StatelessWidget {
  const AppSegmentedToggle({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    this.expand = false,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final (index, option) in options.indexed)
            if (expand)
              Expanded(child: _tab(theme, index, option))
            else
              _tab(theme, index, option),
        ],
      ),
    );
  }

  Widget _tab(ThemeData theme, int index, String option) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          option,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
