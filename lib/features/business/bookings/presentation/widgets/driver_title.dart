import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/bookings/presentation/widgets/selected_type.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class DriverTitle extends StatelessWidget {
  const DriverTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sara Mohammed',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Car Type',
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const Spacer(),
        SelectedType(
          textColor: context.appColors.warning,
          text: context.l10n.waiting,
          // ponytail: no token for this decorative color
          conColor: const Color(0xFFFAD6B8),
        ),
      ],
    );
  }
}
