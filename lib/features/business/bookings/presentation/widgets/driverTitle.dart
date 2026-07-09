import 'package:flutter/material.dart';
import 'package:osta/features/business/bookings/presentation/widgets/selectedType.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class DriverTitle extends StatelessWidget {
  const DriverTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return                     Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sara Mohammed',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Car Type',
              style:
              Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF67775A),
              ),
            ),
          ],
        ),
        const Spacer(),
        SelectedType(
          textColor: const Color(0xFFEB8E4B),
          text: context.l10n.waiting,
          conColor: const Color(0xFFFAD6B8),
        ),
      ],
    );

  }
}
