import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/create/bloc/booking_create_bloc.dart';
import 'package:osta/features/customer/booking/presentation/create/widgets/booking_bottom_bar.dart';
import 'package:osta/features/customer/booking/presentation/create/widgets/booking_slots.dart';
import 'package:osta/features/customer/booking/presentation/create/widgets/day_selector.dart';
import 'package:osta/features/customer/booking/presentation/create/widgets/service_check_tile.dart';
import 'package:osta/features/customer/map/data/models/center_detail.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_section_title.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class BookingCreateArgs {
  const BookingCreateArgs({
    required this.centerId,
    required this.centerName,
    required this.services,
  });

  final String centerId;
  final String centerName;
  final List<CenterService> services;
}

class BookingCreatePage extends StatelessWidget {
  const BookingCreatePage({required this.args, super.key});

  final BookingCreateArgs args;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<BookingCreateBloc>(param1: args.centerId)
          ..add(const BookingCreateStarted()),
    child: _BookingCreateView(args: args),
  );
}

class _BookingCreateView extends StatelessWidget {
  const _BookingCreateView({required this.args});

  final BookingCreateArgs args;

  double _total(Set<String> selected) => args.services
      .where((s) => selected.contains(s.id))
      .fold<double>(0, (sum, s) => sum + s.price);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(centerTitle: false, title: args.centerName),
      body: BlocConsumer<BookingCreateBloc, BookingCreateState>(
        listener: (context, state) {
          final booking = state.createdBooking;
          if (booking != null) {
            context.pushReplacement(
              AppRoutes.bookingStatus,
              extra: booking.id,
            );
          } else if (state.submitFailed) {
            AppToaster.showError(l10n.bookingCreateError);
          }
        },
        builder: (context, state) {
          final bloc = context.read<BookingCreateBloc>();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    AppSectionTitle(title: l10n.bookingCreateServices),
                    const SizedBox(height: AppSpacing.sm),
                    ...args.services.map(
                      (s) => ServiceCheckTile(
                        label: s.name,
                        price:
                            '${s.price.toStringAsFixed(0)} ${l10n.currencyEgp}',
                        selected: state.selectedServiceIds.contains(s.id),
                        onChanged: (_) =>
                            bloc.add(BookingCreateServiceToggled(s.id)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DaySelector(
                      selectedDate: state.date,
                      onDateSelected: (date) =>
                          bloc.add(BookingCreateDateSelected(date)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSectionTitle(title: l10n.bookingCreateSlots),
                    const SizedBox(height: AppSpacing.sm),
                    BookingSlots(state: state),
                  ],
                ),
              ),
              BookingBottomBar(
                totalPrice:
                    '${_total(state.selectedServiceIds).toStringAsFixed(0)} '
                    '${l10n.currencyEgp}',
                onConfirm: state.canSubmit
                    ? () => bloc.add(const BookingCreateSubmitted())
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
