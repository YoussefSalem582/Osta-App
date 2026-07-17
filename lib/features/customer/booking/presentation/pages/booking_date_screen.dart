import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/booking_fixtures.dart';
import 'package:osta/features/customer/booking/presentation/widgets/booking_date/booking_bottom_bar.dart';
import 'package:osta/features/customer/booking/presentation/widgets/booking_date/booking_summary_card.dart';
import 'package:osta/features/customer/booking/presentation/widgets/booking_date/day_selector.dart';
import 'package:osta/features/customer/booking/presentation/widgets/booking_date/temporary_reservation_banner.dart';
import 'package:osta/features/customer/booking/presentation/widgets/booking_date/time_slot_grid.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

const List<String> availableSlots = [
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '01:00',
  '02:00',
  '03:00',
];

class BookingDateScreen extends StatefulWidget {
  const BookingDateScreen({super.key});

  @override
  State<BookingDateScreen> createState() => BookingDateScreenState();
}

class BookingDateScreenState extends State<BookingDateScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  int timerResetTrigger = 0;

  bool get selectionComplete => selectedTime != null;

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedTime = null;
    });
  }

  void onTimeSelected(String time) {
    setState(() {
      selectedTime = time;
      timerResetTrigger++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppTopBar(
        centerTitle: false,
        title: l10n.bookAppointment,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              children: [
                if (selectionComplete) ...[
                  TemporaryReservationBanner(
                    resetTrigger: timerResetTrigger,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                DaySelector(
                  selectedDate: selectedDate,
                  onDateSelected: onDateSelected,
                ),

                const SizedBox(height: AppSpacing.lg),

                TimeSlotGrid(
                  timeSlots: availableSlots,
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  onTimeSelected: onTimeSelected,
                ),

                const SizedBox(height: AppSpacing.lg),

                BookingSummaryCard(
                  sectionLabel: l10n.bookingService,
                  vehicleDetail: l10n.bookingServiceDetail,
                  serviceDetail: l10n.bookingServiceSubDetail,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          BookingBottomBar(
            totalPrice: BookingFixtures.totalPrice,
            onConfirm: selectionComplete ? () {} : null,
          ),
        ],
      ),
    );
  }
}
