import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/bookings/data/model/business_booking.dart';
import 'package:osta/features/business/bookings/presentation/bloc/business_bookings_bloc.dart';
import 'package:osta/features/business/bookings/presentation/widgets/assign_mechanic_sheet.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_pill.dart';
import 'package:osta/shared/ui/app_text_field.dart';

class BusinessBookingCard extends StatelessWidget {
  const BusinessBookingCard({required this.booking, super.key});

  final BusinessBooking booking;

  Future<void> _reject(BuildContext context) async {
    final bloc = context.read<BusinessBookingsBloc>();
    final reason = await _askReason(context);
    if (reason == null || reason.isEmpty || !context.mounted) return;
    bloc.add(BusinessBookingsRejectRequested(booking.id, reason));
  }

  Future<void> _assign(BuildContext context) async {
    final bloc = context.read<BusinessBookingsBloc>();
    final result = await showAssignMechanicSheet(context);
    if (result == null || !context.mounted) return;
    bloc.add(BusinessBookingsAssignRequested(booking.id, result.mechanicId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bloc = context.read<BusinessBookingsBloc>();
    final scheduled = booking.scheduledAt;
    final when = scheduled == null
        ? ''
        : '${scheduled.day}/${scheduled.month} '
              '${scheduled.hour.toString().padLeft(2, '0')}:'
              '${scheduled.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.customer?.name ?? booking.reference,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppPill(
                label: _statusLabel(l10n, booking.status),
                background: theme.colorScheme.surfaceContainerHighest,
                foreground: theme.colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                when,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (booking.totalAmount != null)
                Text(
                  '${booking.totalAmount!.toStringAsFixed(0)} '
                  '${l10n.currencyEgp}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (booking.assignedMechanic != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l10n.mechanicLabel}: ${booking.assignedMechanic!.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _actions(context, bloc),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, BusinessBookingsBloc bloc) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final buttons = <Widget>[];
    switch (booking.status) {
      case 'pending':
        buttons.add(
          AppButton(
            label: l10n.accept,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
            ),
            onPressed: () =>
                bloc.add(BusinessBookingsAcceptRequested(booking.id)),
          ),
        );
        buttons.add(
          AppButton(
            label: l10n.decline,
            variant: AppButtonVariant.secondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => _reject(context),
          ),
        );
      case 'confirmed':
        buttons.add(
          AppButton(
            label: l10n.bookingStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
            ),
            onPressed: () => bloc.add(
              BusinessBookingsAdvanceRequested(booking.id, 'in_progress'),
            ),
          ),
        );
        buttons.add(
          AppButton(
            label: l10n.assignMechanicCta,
            variant: AppButtonVariant.secondary,
            onPressed: () => _assign(context),
          ),
        );
      case 'in_progress':
        buttons.add(
          AppButton(
            label: l10n.bookingComplete,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
            ),
            onPressed: () => bloc.add(
              BusinessBookingsAdvanceRequested(booking.id, 'completed'),
            ),
          ),
        );
        buttons.add(
          AppButton(
            label: l10n.assignMechanicCta,
            variant: AppButtonVariant.secondary,
            onPressed: () => _assign(context),
          ),
        );
    }
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          Expanded(child: buttons[i]),
          if (i < buttons.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'pending' => l10n.waiting,
  'confirmed' => l10n.sure,
  'in_progress' => l10n.underImplementation,
  'completed' => l10n.completed,
  'cancelled' => l10n.statusCancelled,
  'invoiced' => l10n.bookingStateInvoiced,
  _ => status,
};

/// Small dialog collecting the required rejection reason.
Future<String?> _askReason(BuildContext context) {
  final controller = TextEditingController();
  final l10n = context.l10n;
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.rejectReasonTitle),
      content: AppTextField(
        controller: controller,
        hint: l10n.rejectReasonHint,
        minLines: 2,
        maxLines: 4,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text.trim()),
          child: Text(l10n.decline),
        ),
      ],
    ),
  );
}
