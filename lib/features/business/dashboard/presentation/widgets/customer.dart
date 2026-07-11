import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/presentation/widgets/confirm_or_decline.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class Customer extends StatelessWidget {
  const Customer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConfirmOrDecline(
                  bgColor: AppColors.brandGreen,
                  color: Theme.of(context).colorScheme.onPrimary,
                  text: context.l10n.confirm,
                ),
                ConfirmOrDecline(
                  bgColor: Theme.of(context).colorScheme.surface,

                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
