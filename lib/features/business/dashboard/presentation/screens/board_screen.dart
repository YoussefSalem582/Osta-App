import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/appbar.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/customer.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/income_card.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/item_type.dart';
import 'package:osta/shared/extensions/context_ext.dart';

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
    final l10n = context.l10n;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          final bloc = context.read<DashboardBloc>()
            ..add(const DashboardLoadRequested());
          // Keep the spinner up until the refresh settles, matching the old
          // `await cubit.load()`.
          await bloc.stream.firstWhere((state) => state is! DashboardLoading);
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final data = state is DashboardLoaded ? state.data : null;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  const AppBarWidget(),
                  const SizedBox(height: AppSpacing.md),
                  IncomeCard(
                    revenue: data?.revenue,
                    loading: state is DashboardLoading,
                    error: state is DashboardError,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ItemType(
                          text1: '${data?.today ?? 0}',
                          text2: l10n.dashboardToday,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: ItemType(
                          text1: '${data?.pending ?? 0}',
                          text2: l10n.waiting,
                          color: context.appColors.warning,
                        ),
                      ),
                      Expanded(
                        child: ItemType(
                          text1: '${data?.completed ?? 0}',
                          text2: l10n.completed,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.newOrders,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Text(
                            '${data?.pending ?? 0} ${l10n.neew}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandGreen,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Customer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
