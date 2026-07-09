import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class TabPill extends StatelessWidget {
  const TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
