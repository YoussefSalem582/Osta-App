import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Greeting + name on the leading (start) side; the bell trails. Mirrors
        // correctly in RTL (start = right).
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Icon(
              Icons.notifications_none,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _greeting(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }
}
