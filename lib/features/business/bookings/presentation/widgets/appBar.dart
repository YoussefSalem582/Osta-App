import 'package:flutter/material.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                Text(
                  context.l10n.list,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF909D93),
                        fontSize: 16,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  context.l10n.reservation,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
