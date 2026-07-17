import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/data/model.dart/booking_item.dart';
import 'package:osta/features/customer/booking/presentation/widgets/my_bookings/booking_list.dart';
import 'package:osta/features/customer/booking/presentation/widgets/my_bookings/tab_pill.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

const upcoming = [
  BookingItem(
    id: 'OSTA-B2046',
    centerName: 'مركز النصر للصيانة',
    address: 'شبرا زيد وفلر',
    date: 'النهاردة ١٢:٠٠',
    price: 'ج٣٦٠',
    status: BookingStatus.pending,
  ),
  BookingItem(
    id: 'OSTA-B2047',
    centerName: 'ورشة الأمانة',
    address: 'مكمش قوارص الداخلية',
    date: 'بكرة ١٠:٣٠',
    price: 'ج٤٢٠',
    status: BookingStatus.confirmed,
  ),
];

const past = [
  BookingItem(
    id: 'OSTA-B2040',
    centerName: 'مركز النصر للصيانة',
    address: 'مواتير وطزارب',
    date: '٢ يناير',
    price: 'ج١٨٠',
    status: BookingStatus.completed,
  ),
];

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: const MyBookingsView(),
  );
}

class MyBookingsView extends StatefulWidget {
  const MyBookingsView({super.key});

  @override
  State<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(
                children: [
                  TabPill(
                    label: l10n.bookingUpcomingCount(upcoming.length),
                    selected: selectedTab == 0,
                    onTap: () => setState(() => selectedTab = 0),
                  ),
                  TabPill(
                    label: l10n.bookingPast,
                    selected: selectedTab == 1,
                    onTap: () => setState(() => selectedTab = 1),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: selectedTab == 0
                ? BookingList(
                    bookings: upcoming,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  )
                : BookingList(
                    bookings: past,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
          ),
        ],
      ),
    );
  }
}
