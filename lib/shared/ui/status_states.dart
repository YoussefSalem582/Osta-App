import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';

/// Shared empty / error / loading placeholders so feature screens never
/// hand-roll status layouts.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      _StatusLayout(icon: icon, title: title, message: message);
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
    super.key,
  });

  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _StatusLayout(
    icon: Icons.error_outline,
    iconColor: Theme.of(context).colorScheme.error,
    title: title,
    message: message,
    action: onRetry == null
        ? null
        : AppButton(
            label: retryLabel ?? context.l10n.retry,
            onPressed: onRetry,
            variant: AppButtonVariant.secondary,
            icon: Icons.refresh,
          ),
  );
}

class LoadingState extends StatelessWidget {
  const LoadingState({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _StatusLayout extends StatelessWidget {
  const _StatusLayout({
    required this.icon,
    required this.title,
    this.iconColor,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: iconColor ?? context.appColors.accent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
