import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/data/model.dart/booking_item.dart';
import 'package:osta/features/customer/booking/presentation/widgets/my_bookings/booking_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class BookingList extends StatelessWidget {
  const BookingList({ 
    required this.bookings,
    required this.colorScheme,
    required this.textTheme,
    super.key
  });

  final List<BookingItem> bookings;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.bookingEmpty,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => BookingCard(
        booking: bookings[i],
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
    );
  }
}
