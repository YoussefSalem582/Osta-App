import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/repo/business_service_repo.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';

/// One catalogue service: tap to edit, switch to retire/restore (`is_active`),
/// delete to remove. Unlike the onboarding `ServiceToggleCard` (toggle XOR
/// remove), a managed service needs all three.
class ServiceManagementRow extends StatelessWidget {
  const ServiceManagementRow({
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Service service;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final subtitle = service.category ?? service.description ?? '';

    return AppCard(
      onTap: onEdit,
      elevation: AppElevation.low,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${service.price.toStringAsFixed(0)} ${l10n.currencyEgp}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: service.isActive, onChanged: onToggle),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: theme.colorScheme.error,
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }
}
