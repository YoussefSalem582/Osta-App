import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/widgets/live_booking/booking_timeline.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class LiveBookingScreen extends StatelessWidget {
  const LiveBookingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppTopBar(
      centerTitle: false,
      title: context.l10n.bookingStatus,
      subtitle: BookingView.bookingCode,
    ),
    body: const BookingView(),
  );
}

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  static const bookingCode = 'OSTA-B2046';
  static const mechanicName = 'الميكانيكي: محمود';
  static const centerName = 'مركز النصر · بنها — ٣٠م';
  static const liveChannel = 'bookings.B204';
  static const BookingStep activeStep = BookingStep.inProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        StatusCard(
          mechanicName: mechanicName,
          centerName: centerName,
          statusLabel: l10n.workingOnYourCar,
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          l10n.bookingTimeline,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        const AppCard(
          child: BookingTimeline(activeStep: activeStep),
        ),

        const SizedBox(height: AppSpacing.md),

        LiveUpdatesBanner(
          notice: l10n.liveUpdatesNotice(liveChannel),
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton(
          label: l10n.contactCenter,
          icon: Icons.phone_outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.mechanicName,
    required this.centerName,
    required this.statusLabel,
    super.key,
  });

  final String mechanicName;
  final String centerName;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brandGreen,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.live,
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Text('🔧 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  statusLabel,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            mechanicName,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          Text(
            centerName,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveUpdatesBanner extends StatelessWidget {
  const LiveUpdatesBanner({required this.notice, super.key});

  final String notice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              notice,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
