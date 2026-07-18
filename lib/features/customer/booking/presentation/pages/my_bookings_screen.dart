import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/data/model/booking.dart';
import 'package:osta/features/customer/booking/data/model/booking_item.dart';
import 'package:osta/features/customer/booking/presentation/bloc/bookings_bloc.dart';
import 'package:osta/features/customer/booking/presentation/widgets/my_bookings/booking_list.dart';
import 'package:osta/features/customer/booking/presentation/widgets/my_bookings/tab_pill.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/status_states.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: const MyBookingsView(),
  );
}

class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => BookingsBloc()..add(const BookingsLoadRequested()),
    child: const _MyBookingsBody(),
  );
}

class _MyBookingsBody extends StatefulWidget {
  const _MyBookingsBody();

  @override
  State<_MyBookingsBody> createState() => _MyBookingsBodyState();
}

class _MyBookingsBodyState extends State<_MyBookingsBody> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<BookingsBloc, BookingsState>(
      builder: (context, state) {
        if (state is BookingsLoading || state is BookingsInitial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state is BookingsError) {
          return ErrorState(
            title: l10n.bookingsErrorTitle,
            message: state.message,
            onRetry: () => context.read<BookingsBloc>().add(
              const BookingsLoadRequested(),
            ),
          );
        }
        final loaded = state as BookingsLoaded;
        final upcoming = loaded.upcoming;
        final past = loaded.past;
        final items = (selectedTab == 0 ? upcoming : past)
            .map(_toItem)
            .toList();

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
                child: RefreshIndicator.adaptive(
                  onRefresh: () async => context.read<BookingsBloc>().add(
                    const BookingsLoadRequested(),
                  ),
                  child: BookingList(
                    bookings: items,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Maps an API [Booking] onto the presentational [BookingItem] the existing
/// cards render. On the list endpoint `center`/`items` aren't eager-loaded, so
/// the reference stands in for the (absent) center name.
BookingItem _toItem(Booking b) {
  final scheduled = b.scheduledAt;
  final date = scheduled == null
      ? ''
      : '${scheduled.day}/${scheduled.month} '
            '${scheduled.hour.toString().padLeft(2, '0')}:'
            '${scheduled.minute.toString().padLeft(2, '0')}';
  final amount = b.totalAmount;
  return BookingItem(
    id: b.id,
    centerName: b.center?.name ?? b.reference,
    address: b.center?.city ?? '',
    date: date,
    price: amount == null ? '' : '${amount.toStringAsFixed(0)} ج.م',
    status: _mapStatus(b.status),
  );
}

BookingStatus _mapStatus(String status) => switch (status) {
  'pending' => BookingStatus.pending,
  'confirmed' || 'in_progress' => BookingStatus.confirmed,
  'completed' || 'invoiced' => BookingStatus.completed,
  'cancelled' => BookingStatus.cancelled,
  _ => BookingStatus.pending,
};
