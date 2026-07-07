import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// Unauthenticated landing after the role chooser. Routes into the shared auth
/// form pre-set to login or register via `?mode=`; social sign-in is a stub
/// until implemented.
class AuthChoosePage extends StatelessWidget {
  const AuthChoosePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<SessionController>();
    return BrandScaffold(
      logo: AppImages.fullLogo,
      title: l10n.authChooseTitle,
      subtitle: l10n.authChooseSubtitle,
      // Back re-opens onboarding (the guard reroutes on the emitted state;
      // there's no push stack to pop). Role + language stay chosen.
      onBack: session.resetOnboarding,
      children: [
        AppButton(
          label: l10n.authSignInTitle,
          onPressed: () => context.go('${AppRoutes.auth}?mode=login'),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.authRegisterTitle,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.go('${AppRoutes.auth}?mode=register'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _OrDivider(label: l10n.authChooseOr),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.continueWithGoogle,
          variant: AppButtonVariant.secondary,
          icon: Icons.g_mobiledata,
          onPressed: () => _comingSoon(context, l10n.socialComingSoon),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.continueWithApple,
          variant: AppButtonVariant.secondary,
          icon: Icons.apple,
          onPressed: () => _comingSoon(context, l10n.socialComingSoon),
        ),
      ],
    );
  }

  void _comingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// "— or continue with —" separator.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
