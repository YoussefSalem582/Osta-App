import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/data/model/maintenance_record.dart';
import 'package:osta/features/customer/garage/presentation/cubit/maintenance_cubit.dart';
import 'package:osta/features/customer/garage/presentation/cubit/maintenance_state.dart';
import 'package:osta/features/customer/garage/presentation/widgets/add_maintenance_record_sheet.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// One vehicle's maintenance/expense history (`vehicles/{id}/maintenance`).
/// Add-only — the repo exposes no update/delete endpoint, so there is no
/// edit or delete UI here. PDF export (`MaintenanceRepo.exportPdf`) is a
/// deliberate scope cut for this pass.
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List<MaintenanceRecord> _records = [];

  Future<void> _onAddRecord(BuildContext context) async {
    final cubit = context.read<MaintenanceCubit>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const AddMaintenanceRecordSheet(),
      ),
    );
    if (saved == true) {
      if (context.mounted) {
        AppToaster.showMessage(context.l10n.maintenanceAddSuccess);
      }
      unawaited(cubit.loadHistory());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = MaintenanceCubit(widget.vehicleId);
        unawaited(cubit.loadHistory());
        return cubit;
      },
      child: BlocConsumer<MaintenanceCubit, MaintenanceState>(
        listener: (context, state) {
          if (state is MaintenanceSuccess) {
            setState(() => _records = state.records);
          }
        },
        builder: (context, state) {
          final l10n = context.l10n;

          if (state is MaintenanceLoading || state is MaintenanceInitial) {
            return Scaffold(
              appBar: AppTopBar(
                centerTitle: false,
                title: l10n.maintenanceHistoryTitle,
              ),
              body: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          if (state is MaintenanceError) {
            return Scaffold(
              appBar: AppTopBar(
                centerTitle: false,
                title: l10n.maintenanceHistoryTitle,
              ),
              body: Center(
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppTopBar(
              centerTitle: false,
              title: l10n.maintenanceHistoryTitle,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: IconButton(
                    onPressed: () => unawaited(_onAddRecord(context)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    tooltip: l10n.maintenanceAddRecordTooltip,
                  ),
                ),
              ],
            ),
            body: _records.isEmpty
                ? EmptyState(
                    title: l10n.maintenanceEmptyTitle,
                    message: l10n.maintenanceEmptySubtitle,
                    icon: Icons.build_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: _records.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _MaintenanceRecordRow(record: _records[index]),
                  ),
          );
        },
      ),
    );
  }
}

class _MaintenanceRecordRow extends StatelessWidget {
  const _MaintenanceRecordRow({required this.record});

  final MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final performedAt = record.performedAt;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.typeLabel,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (performedAt != null)
                Text(
                  DateFormat.yMMMd(locale).format(performedAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
          if ((record.description ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              record.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (record.mileage != null || record.cost != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (record.mileage != null) ...[
                  Icon(
                    Icons.speed_rounded,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${record.mileage} ${l10n.km}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (record.mileage != null && record.cost != null)
                  const SizedBox(width: AppSpacing.md),
                if (record.cost != null) ...[
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.maintenanceCostEgp(record.cost!),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
