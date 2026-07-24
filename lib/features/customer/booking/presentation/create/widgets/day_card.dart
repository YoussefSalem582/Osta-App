import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class DayCard extends StatelessWidget {
  const DayCard({
    required this.dayName,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String dayName;
  final String dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = selected
        ? colorScheme.primary
        : colorScheme.surface;
    final textColor = selected ? colorScheme.onPrimary : colorScheme.onSurface;
    final subtitleColor = selected
        ? colorScheme.onPrimary.withValues(alpha: 0.75)
        : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 56,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: selected
              ? null
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayNumber,
              style: textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              dayName,
              style: textTheme.bodySmall?.copyWith(
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
