import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/data/model/booking.dart';
import 'package:osta/features/customer/booking/presentation/bloc/booking_detail/booking_detail_bloc.dart';
import 'package:osta/features/customer/booking/presentation/widgets/live_booking/booking_timeline.dart';
import 'package:osta/features/customer/booking/presentation/widgets/live_booking/status_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

class LiveBookingScreen extends StatelessWidget {
  const LiveBookingScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        BookingDetailBloc(bookingId)..add(const BookingDetailLoadRequested()),
    child: const _LiveBookingView(),
  );
}

class _LiveBookingView extends StatefulWidget {
  const _LiveBookingView();

  @override
  State<_LiveBookingView> createState() => _LiveBookingViewState();
}

class _LiveBookingViewState extends State<_LiveBookingView> {
  Booking? _booking;

  Future<void> _reschedule(BuildContext context) async {
    final now = DateTime.now();
    final base = _booking?.scheduledAt ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      initialDate: base.isBefore(now) ? now : base,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !context.mounted) return;
    final at = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    context.read<BookingDetailBloc>().add(
      BookingDetailRescheduleRequested(at),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.bookingCancelDialogTitle,
      message: l10n.bookingCancelDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.bookingCancelAction,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    context.read<BookingDetailBloc>().add(
      const BookingDetailCancelRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(
        centerTitle: false,
        title: l10n.bookingStatus,
        subtitle: _booking?.reference,
      ),
      body: BlocConsumer<BookingDetailBloc, BookingDetailState>(
        listener: (context, state) {
          if (state is BookingDetailLoaded) {
            setState(() => _booking = state.booking);
          } else if (state is BookingDetailActionError) {
            AppToaster.showError(state.message);
          }
        },
        builder: (context, state) {
          final booking = _booking;
          if (booking == null) {
            if (state is BookingDetailError) {
              return ErrorState(
                title: l10n.bookingDetailErrorTitle,
                message: state.message,
                onRetry: () => context.read<BookingDetailBloc>().add(
                  const BookingDetailLoadRequested(),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              _content(context, booking),
              if (state is BookingDetailActing)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, Booking booking) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final center = booking.center;
    final mechanic = booking.assignedMechanic;

    return RefreshIndicator.adaptive(
      onRefresh: () async => context.read<BookingDetailBloc>().add(
        const BookingDetailLoadRequested(),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        children: [
          StatusCard(
            mechanicName: mechanic == null
                ? ''
                : '${l10n.mechanicLabel}: ${mechanic.name}',
            centerName: center == null
                ? booking.reference
                : '${center.name} · ${center.city}',
            statusLabel: _statusLabel(l10n, booking.status),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.bookingTimeline,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(child: BookingTimeline(activeStep: _step(booking.status))),
          const SizedBox(height: AppSpacing.lg),
          ..._actions(context, booking),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context, Booking booking) {
    final l10n = context.l10n;
    final bloc = context.read<BookingDetailBloc>();
    final status = booking.status;
    final widgets = <Widget>[];

    if (status == 'pending') {
      widgets.add(
        AppButton(
          label: l10n.confirm,
          onPressed: () => bloc.add(const BookingDetailConfirmRequested()),
        ),
      );
    }
    if (status == 'pending' || status == 'confirmed') {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
      }
      widgets.add(
        AppButton(
          label: l10n.bookingReschedule,
          variant: AppButtonVariant.secondary,
          icon: Icons.event_repeat_outlined,
          onPressed: () => _reschedule(context),
        ),
      );
    }
    if (status == 'pending' ||
        status == 'confirmed' ||
        status == 'in_progress') {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
      }
      widgets.add(
        AppButton(
          label: l10n.bookingCancelAction,
          variant: AppButtonVariant.text,
          onPressed: () => _cancel(context),
        ),
      );
    }
    return widgets;
  }

  static BookingStep _step(String status) => switch (status) {
    'confirmed' => BookingStep.confirmed,
    'in_progress' => BookingStep.inProgress,
    'completed' || 'invoiced' => BookingStep.completed,
    _ => BookingStep.requested,
  };

  static String _statusLabel(AppLocalizations l10n, String status) =>
      switch (status) {
        'confirmed' => l10n.bookingStateConfirmed,
        'in_progress' => l10n.workingOnYourCar,
        'completed' => l10n.bookingStateCompleted,
        'invoiced' => l10n.bookingStateInvoiced,
        'cancelled' => l10n.bookingStateCancelled,
        _ => l10n.bookingStatePending,
      };
}
