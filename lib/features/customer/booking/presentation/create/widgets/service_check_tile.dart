import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';

/// A checkbox row for a single bookable service: name on the left, price on
/// the right.
class ServiceCheckTile extends StatelessWidget {
  const ServiceCheckTile({
    required this.label,
    required this.price,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String price;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: selected,
      onChanged: onChanged,
      activeColor: AppColors.brandGreen,
      title: Text(label, style: theme.textTheme.bodyLarge),
      secondary: Text(
        price,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.brandGreen,
        ),
      ),
    );
  }
}
