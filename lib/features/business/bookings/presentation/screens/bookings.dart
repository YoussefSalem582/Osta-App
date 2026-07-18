import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/bookings/presentation/bloc/business_bookings_bloc.dart';
import 'package:osta/features/business/bookings/presentation/widgets/booking_card.dart';
import 'package:osta/features/business/bookings/presentation/widgets/booking_filter_row.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/appbar.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

/// The provider booking queue — a live feed over `GET /business/bookings` with
/// per-card accept / reject / advance-status / assign-mechanic actions. Shown as
/// the business shell's center calendar action.
class Bookings extends StatelessWidget {
  const Bookings({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        BusinessBookingsBloc()..add(const BusinessBookingsLoadRequested()),
    child: const _BookingsView(),
  );
}

class _BookingsView extends StatelessWidget {
  const _BookingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessBookingsBloc, BusinessBookingsState>(
      listenWhen: (previous, current) => current.actionError != null,
      listener: (context, state) => AppToaster.showError(state.actionError!),
      builder: (context, state) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBarWidget(),
                  const SizedBox(height: AppSpacing.md),
                  BookingFilterRow(active: state.statusFilter),
                  const SizedBox(height: AppSpacing.md),
                  _body(context, state),
                ],
              ),
            ),
            if (state.acting)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, BusinessBookingsState state) {
    final l10n = context.l10n;
    if (state.status == BusinessBookingsStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == BusinessBookingsStatus.error) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: ErrorState(
          title: l10n.businessBookingsErrorTitle,
          message: state.error,
          onRetry: () => context.read<BusinessBookingsBloc>().add(
            const BusinessBookingsLoadRequested(),
          ),
        ),
      );
    }
    if (state.bookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: EmptyState(
          icon: Icons.calendar_today_outlined,
          title: l10n.businessBookingsEmpty,
        ),
      );
    }
    return Column(
      children: [
        for (final booking in state.bookings) ...[
          BusinessBookingCard(booking: booking),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
