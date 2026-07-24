import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/presentation/create/bloc/booking_create_bloc.dart';
import 'package:osta/features/customer/booking/presentation/create/widgets/time_slot_grid.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Renders the available-time-slots section: loading/error/empty states, or
/// the [TimeSlotChip] wrap for the selected day.
class BookingSlots extends StatelessWidget {
  const BookingSlots({required this.state, super.key});

  final BookingCreateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (state.availabilityStatus == AvailabilityStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    if (state.availabilityStatus == AvailabilityStatus.error) {
      return Text(
        state.availabilityError ?? l10n.bookingCreateSlotsError,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }
    if (state.slots.isEmpty) {
      return Text(
        l10n.bookingCreateNoSlots,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final bloc = context.read<BookingCreateBloc>();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final slot in state.slots)
          if (slot.start != null)
            TimeSlotChip(
              label: TimeOfDay.fromDateTime(slot.start!).format(context),
              selected: state.selectedSlot == slot,
              disabled: !slot.available,
              onTap: () => bloc.add(BookingCreateSlotSelected(slot)),
            ),
      ],
    );
  }
}
