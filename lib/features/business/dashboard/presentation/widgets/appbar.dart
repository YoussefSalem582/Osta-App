import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.control,
          style:
              Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF67775A),
              ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.centerName,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
            ),

          ],
        ),
      ],
    );
  }
}
