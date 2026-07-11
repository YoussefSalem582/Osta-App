import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/bookings/presentation/widgets/custom_row.dart';
import 'package:osta/features/business/bookings/presentation/widgets/driver_title.dart';
import 'package:osta/features/business/bookings/presentation/widgets/selected_type.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/appbar.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/confirm_or_decline.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class Bookings extends StatelessWidget {
  const Bookings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          const AppBarWidget(),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Row(
            children: [
              SelectedType(
                textColor: Theme.of(context).colorScheme.onPrimary,
                text: context.l10n.all,
                conColor: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              SelectedType(
                textColor: Theme.of(context).colorScheme.onSurface,
                text: context.l10n.waiting,
                conColor: Theme.of(context).colorScheme.surface,
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              SelectedType(
                textColor: Theme.of(context).colorScheme.onSurface,

                text: context.l10n.sure,
                conColor: Theme.of(context).colorScheme.surface,
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              SelectedType(
                textColor: Theme.of(context).colorScheme.onSurface,
                text: context.l10n.underImplementation,
                conColor: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.lg),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                children: [
                  const DriverTitle(),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    endIndent: 8,
                    indent: 8,
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  CustomRow(
                    text1: context.l10n.exchangeOilAndFilter,
                    text2: '250 EGP',
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  CustomRow(
                    text1: context.l10n.appointment,
                    text2: '12:00 Today',
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  Row(
                    children: [
                      ConfirmOrDecline(
                        color: Theme.of(context).colorScheme.onPrimary,
                        bgColor: AppColors.brandGreen,
                        text: context.l10n.confirm,
                      ),
                      const SizedBox(
                        width: AppSpacing.sm,
                      ),
                      ConfirmOrDecline(
                        color: Theme.of(context).colorScheme.error,
                        bgColor: Theme.of(context).colorScheme.errorContainer,
                        text: context.l10n.decline,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        Text(
                          context.l10n.mechanicalSupport,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
