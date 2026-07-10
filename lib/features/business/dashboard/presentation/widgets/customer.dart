import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/confirm_or_decline.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class Customer extends StatelessWidget {
  const Customer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Sara Mohamed',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Oil Exchange 1200',
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF67775A),
                  ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConfirmOrDecline(
                  bgColor: AppColors.brandGreen,
                  color: const Color(0xFFFFFFFF),
                  text: context.l10n.confirm,
                ),
                ConfirmOrDecline(
                  bgColor: const Color(0xFFFFFFFF),

                  color: const Color(0xFF67775A),
                  text: context.l10n.decline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
