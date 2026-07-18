import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/bookings/presentation/bloc/business_bookings_bloc.dart';
import 'package:osta/shared/extensions/context_ext.dart';

const _filters = <String?>[
  null,
  'pending',
  'confirmed',
  'in_progress',
  'completed',
];

class BookingFilterRow extends StatelessWidget {
  const BookingFilterRow({required this.active, super.key});

  final String? active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _filters) ...[
            ChoiceChip(
              label: Text(_filterLabel(l10n, f)),
              selected: active == f,
              onSelected: (_) => context.read<BusinessBookingsBloc>().add(
                BusinessBookingsFilterChanged(f),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

String _filterLabel(AppLocalizations l10n, String? f) => switch (f) {
  'pending' => l10n.waiting,
  'confirmed' => l10n.sure,
  'in_progress' => l10n.underImplementation,
  'completed' => l10n.completed,
  _ => l10n.all,
};
