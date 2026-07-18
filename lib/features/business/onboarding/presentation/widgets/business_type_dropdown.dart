import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Business-type picker shared by the onboarding identity step and the
/// post-onboarding profile editor — same options, same labels.
class BusinessTypeDropdown extends StatelessWidget {
  const BusinessTypeDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const businessTypes = [
    'workshop',
    'dealership',
    'mobile',
    'tire_shop',
    'car_wash',
  ];

  static String typeLabel(BuildContext context, String wire) {
    final l10n = context.l10n;
    return switch (wire) {
      'dealership' => l10n.businessTypeDealership,
      'mobile' => l10n.businessTypeMobile,
      'tire_shop' => l10n.businessTypeTireShop,
      'car_wash' => l10n.businessTypeCarWash,
      _ => l10n.businessTypeWorkshop,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.businessOnboardingTypeLabel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      items: [
        for (final type in businessTypes)
          DropdownMenuItem(value: type, child: Text(typeLabel(context, type))),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
