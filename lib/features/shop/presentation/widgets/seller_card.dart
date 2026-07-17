import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shop/data/models/product.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Seller row on the product detail screen. The whole card taps through to the
/// owner's storefront (works for both a User and a ServiceCenter owner).
class SellerCard extends StatelessWidget {
  const SellerCard({required this.owner, this.onTap, super.key});

  final ProductOwner owner;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primaryContainer.withValues(
                alpha: 0.4,
              ),
              child: Icon(
                owner.isCenter
                    ? Icons.storefront_outlined
                    : Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shopSellerLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    owner.name ?? l10n.shopSellerFallback,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              Text(
                l10n.shopViewShop,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
