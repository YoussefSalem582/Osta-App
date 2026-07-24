import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class TimeSlotChip extends StatelessWidget {
  const TimeSlotChip({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color backgroundColor;
    final Color textColor;

    if (disabled) {
      backgroundColor = colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      );
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    } else if (selected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: (!disabled && !selected)
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    required this.timeSlots,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeSelected,
    super.key,
  });

  final List<String> timeSlots;
  final DateTime selectedDate;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;

  bool isDisabled(String slot) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selected != today) return false;

    final parts = slot.split(':');
    final slotHour = int.tryParse(parts[0]) ?? 0;
    final slotMinute = int.tryParse(parts[1]) ?? 0;
    final slotTime = DateTime(
      now.year,
      now.month,
      now.day,
      slotHour,
      slotMinute,
    );
    return slotTime.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.availableTimes,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.2,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            return TimeSlotChip(
              label: slot,
              selected: slot == selectedTime,
              disabled: isDisabled(slot),
              onTap: () => onTimeSelected(slot),
            );
          },
        ),
      ],
    );
  }
}
