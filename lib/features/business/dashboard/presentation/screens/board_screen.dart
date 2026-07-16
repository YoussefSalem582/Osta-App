import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/appbar.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/customer.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/item_type.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            const AppBarWidget(),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
                color: AppColors.brandGreen,
                gradient: LinearGradient(
                  colors: [AppColors.brandGreen, context.appColors.success],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  spacing: AppSpacing.md,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.todayIncome,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    Text(
                      '4.250 EGP',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: context.appColors.accent,
                          size: 12,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Text(
                          '12% From yesterday',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: context.appColors.accent,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ItemType(
                  text1: '3',
                  text2: context.l10n.waiting,
                  color: context.appColors.warning,
                ),
                ItemType(
                  text1: '5',
                  text2: context.l10n.sure,
                  color: Theme.of(context).colorScheme.primary,
                ),
                ItemType(
                  text1: '2',
                  text2: context.l10n.underImplementation,
                  // ponytail: decorative stat tint, deliberately not a semantic
                  // role — it means "in progress", not success/warning/error.
                  // Promote to AppColors if a second screen needs the same navy.
                  color: const Color(0xFF09276D),
                ),
                ItemType(
                  text1: '8',
                  text2: context.l10n.completed,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.newOrders,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '1',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandGreen,
                              ),
                        ),

                        Text(
                          context.l10n.neew,
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandGreen,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Customer(),
          ],
        ),
      ),
    );
  }
}
