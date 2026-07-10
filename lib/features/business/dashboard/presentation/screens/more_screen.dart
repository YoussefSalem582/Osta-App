import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/item_type.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/setting.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.brandGreen,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'N',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.centerName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '9KM',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF67775A),
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ItemType(
                  text1: '4.8',
                  text2: context.l10n.evaluation,
                  color: const Color(0xFFE66F1A),
                ),
                ItemType(
                  text1: '312',
                  text2: context.l10n.booking,
                  color: const Color(0xFF1249BF),
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
              height: 8,
            ),
            Text(
              context.l10n.activityManagement,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF67775A),
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(
              height: 8,
            ),
            Setting(
              icon: Icons.people,
              text: context.l10n.technicians,
              onTap: () => context.push(AppRoutes.technicians),
            ),
            const SizedBox(
              height: 8,
            ),
            Setting(
              icon: Icons.build,
              text: context.l10n.generalFile,
            ),
            const SizedBox(
              height: 8,
            ),
            Setting(
              icon: Icons.settings,
              text: context.l10n.operationalCapacity,
            ),
            const SizedBox(
              height: 8,
            ),
            Setting(
              icon: Icons.analytics,
              text: context.l10n.analysis,
            ),
            const SizedBox(
              height: 8,
            ),
            Setting(
              icon: Icons.star_rate,
              text: context.l10n.boxEvaluations,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              context.l10n.account,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF67775A),
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(
              height: 8,
            ),
            Setting(
              icon: Icons.color_lens,
              text: context.l10n.settings,
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
