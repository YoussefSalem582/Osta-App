import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/income_card.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/item_type.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/pending_order_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';

/// Provider board — real revenue + status counts (`GET /business/dashboard`)
/// and a live pending-orders preview (`GET /business/bookings?status=pending`)
/// with in-place accept / decline. No mock data.
class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DashboardBloc()..add(const DashboardLoadRequested()),
    child: const _BoardView(),
  );
}

class _BoardView extends StatelessWidget {
  const _BoardView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (prev, curr) =>
            curr.actionError != null && curr.actionError != prev.actionError,
        listener: (context, state) =>
            AppToaster.showError(context.l10n.dashboardOrderActionError),
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              final bloc = context.read<DashboardBloc>()
                ..add(const DashboardLoadRequested());
              await bloc.stream.firstWhere(
                (s) => s.status != DashboardStatus.loading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(centerName: state.centerName),
                  const SizedBox(height: AppSpacing.md),
                  IncomeCard(
                    revenue: state.data?.revenue,
                    loading: state.status == DashboardStatus.loading,
                    error: state.status == DashboardStatus.error,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatsRow(state: state),
                  const SizedBox(height: AppSpacing.lg),
                  _NewOrdersSection(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.centerName});

  final String? centerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.homeGreetingMorning
        : hour < 18
        ? l10n.homeGreetingAfternoon
        : l10n.homeGreetingEvening;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          // Real center name when the profile endpoint is reachable; the plain
          // section label otherwise — never a hardcoded placeholder name.
          centerName ?? l10n.control,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final data = state.data;
    String count(int? v) =>
        state.status == DashboardStatus.loading ? '…' : '${v ?? 0}';
    return Row(
      children: [
        Expanded(
          child: ItemType(
            icon: Icons.today_outlined,
            text1: count(data?.today),
            text2: l10n.dashboardToday,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ItemType(
            icon: Icons.hourglass_empty_outlined,
            text1: count(data?.pending),
            text2: l10n.waiting,
            color: context.appColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ItemType(
            icon: Icons.check_circle_outline,
            text1: count(data?.completed),
            text2: l10n.completed,
            color: context.appColors.success,
          ),
        ),
      ],
    );
  }
}

class _NewOrdersSection extends StatelessWidget {
  const _NewOrdersSection({required this.state});

  final DashboardState state;

  Future<void> _reject(BuildContext context, String id) async {
    final reason = await _askReason(context);
    if (reason == null || reason.isEmpty || !context.mounted) return;
    context.read<DashboardBloc>().add(DashboardOrderRejected(id, reason));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final orders = state.pendingOrders;
    final loading = state.status == DashboardStatus.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.newOrders,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (orders.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Text(
                  '${orders.length} ${l10n.neew}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (orders.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.dashboardNoNewOrders,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final order in orders)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PendingOrderCard(
                booking: order,
                acting: state.actingId == order.id,
                onAccept: () => context.read<DashboardBloc>().add(
                  DashboardOrderAccepted(order.id),
                ),
                onReject: () => _reject(context, order.id),
              ),
            ),
      ],
    );
  }
}

/// Collects the required rejection reason — mirrors the Bookings screen's
/// reject dialog so a decline from the board records a reason too.
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
