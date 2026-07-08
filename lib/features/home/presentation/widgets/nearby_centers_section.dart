import 'package:flutter/material.dart';
import 'package:osta/features/home/presentation/widgets/center_card.dart';

class NearbyCentersSection extends StatelessWidget {
  const NearbyCentersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مراكز قريبة منك',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              CenterCard(
                name: 'ورشة الأمانة',
                distance: '2 KM',
                rate: 4.6,
              ),
              SizedBox(width: 15),
              CenterCard(
                name: 'مركز النصر',
                distance: '1.2 KM',
                rate: 4.8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
