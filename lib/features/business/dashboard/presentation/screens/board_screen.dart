import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/appbar.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/customer.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/item_type.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7DBD4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD7DBD4),

        title: const AppBarWidget(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: AppColors.brandGreen,
                gradient: LinearGradient(
                  colors: [Color(0xFF155232), Color(0xFF39C67B)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.todayIncome,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: const Color(0xE6FFFFFF),
                          ),
                    ),
                    Text(
                      '4.250 EGP',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xE6FFFFFF),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Color(0xFF8EB819),
                          size: 12,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '12% From yesterday',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: const Color(0xFF8EB819),
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
                  text1: '3',
                  text2: context.l10n.waiting,
                  color: const Color(0xFFE66F1A),
                ),
                ItemType(
                  text1: '5',
                  text2: context.l10n.sure,
                  color: const Color(0xFF12442B),
                ),
                ItemType(
                  text1: '2',
                  text2: context.l10n.underImplementation,
                  color: const Color(0xFF09276D),
                ),
                ItemType(
                  text1: '8',
                  text2: context.l10n.completed,
                  color: const Color(0xFF67775A),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.newOrders,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7EBD4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      8,
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
