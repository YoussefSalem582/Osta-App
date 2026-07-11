import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/widgets/booking_date/day_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    required this.selectedDate,
    required this.onDateSelected,
    this.daysToShow = 14,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  final int daysToShow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final today = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectDay,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: daysToShow,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final date = today.add(Duration(days: index));
              final isSelected = isSameDay(date, selectedDate);

              final dayName = DateFormat('EEE', locale).format(date);
              final dayNumber = DateFormat('d', locale).format(date);

              return DayCard(
                dayName: dayName,
                dayNumber: dayNumber,
                selected: isSelected,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
      ],
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
