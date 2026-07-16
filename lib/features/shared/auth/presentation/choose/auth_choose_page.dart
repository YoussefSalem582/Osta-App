import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';
import 'package:osta/shared/ui/or_divider.dart';

/// Unauthenticated landing after the role chooser. Routes into the shared auth
/// form; `account_type` is taken from the session's active role. Social
/// sign-in is a stub until implemented.
///
/// Back returns to the role-specific marketing carousel (customer or merchant).
class AuthChoosePage extends StatelessWidget {
  const AuthChoosePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<SessionController>();
    final role = session.state.activeRole;
    final isBusiness = role == AppRole.business;

    return BrandScaffold(
      logo: AppImages.fullLogo,
      title: l10n.authChooseTitle,
      subtitle: isBusiness
          ? l10n.authChooseSubtitleBusiness
          : l10n.authChooseSubtitleCustomer,
      onBack: session.resetOnboarding,
      children: [
        AppButton(
          label: isBusiness
              ? l10n.authSignInTitleBusiness
              : l10n.authSignInTitleCustomer,
          onPressed: () => context.go(AppRoutes.login),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: isBusiness
              ? l10n.authRegisterTitleBusiness
              : l10n.authRegisterTitleCustomer,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.go(AppRoutes.register),
        ),
        const SizedBox(height: AppSpacing.lg),
        OrDivider(label: l10n.authChooseOr),
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

  void _comingSoon(BuildContext context, String message) =>
      AppToaster.showMessage(message);
}
