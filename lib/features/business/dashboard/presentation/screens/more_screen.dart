import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/item_type.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/setting.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        color: AppColors.brandGreen,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'N',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.centerName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '9KM',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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
                  text1: '4.8',
                  text2: context.l10n.evaluation,
                  color: context.appColors.warning,
                ),
                ItemType(
                  text1: '312',
                  text2: context.l10n.booking,
                  color: const Color(
                    0xFF1249BF,
                  ), // ponytail: no token for this decorative color
                ),
                ItemType(
                  maxLines: 2,
                  text1: '24',
                  text2: context.l10n.frequentCustomer,
                  color: AppColors.brandGreen,
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              context.l10n.activityManagement,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Setting(
              icon: Icons.people,
              text: context.l10n.technicians,
              onTap: () => context.push(AppRoutes.technicians),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Setting(
              icon: Icons.build,
              text: context.l10n.generalFile,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Setting(
              icon: Icons.settings,
              text: context.l10n.operationalCapacity,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Setting(
              icon: Icons.analytics,
              text: context.l10n.analysis,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Setting(
              icon: Icons.star_rate,
              text: context.l10n.boxEvaluations,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              context.l10n.account,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Setting(
              icon: Icons.color_lens,
              text: context.l10n.settings,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
          ],
        ),
      ),
    );
  }
}
