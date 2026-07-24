import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/profile/data/models/address.dart';
import 'package:osta/features/shared/profile/presentation/profile/widgets/profile_item.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_pill.dart';

/// A single row in the address book list.
class AddressCard extends StatelessWidget {
  const AddressCard({
    required this.address,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String _labelText(BuildContext context) {
    final l10n = context.l10n;
    return switch (address.label) {
      'home' => l10n.addressLabelHome,
      'work' => l10n.addressLabelWork,
      _ => l10n.addressLabelOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final lines = [
      address.line1,
      address.district,
      address.city,
    ].where((s) => s != null && s.isNotEmpty).join('، ');

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const ProfileItemIcon(
                icon: Icons.location_on_outlined,
                color: AppColors.brandGreen,
                size: 40,
                radius: AppRadii.md,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _labelText(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: AppSpacing.sm),
                          AppPill(
                            label: l10n.addressDefaultBadge,
                            background: AppColors.brandGreen.withValues(
                              alpha: 0.12,
                            ),
                            foreground: AppColors.brandGreen,
                            fontWeight: FontWeight.w700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (lines.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        lines,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.delete,
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
