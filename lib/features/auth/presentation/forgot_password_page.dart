import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/presentation/auth_validators.dart';
import 'package:osta/features/auth/presentation/password_recovery_cubit.dart';
import 'package:osta/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// Step 1 of password recovery: collect the email and ask the broker to send a
/// reset link. On success, offers a shortcut to the reset screen.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordRecoveryCubit>(
      create: (_) => getIt<PasswordRecoveryCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    unawaited(
      context.read<PasswordRecoveryCubit>().sendResetLink(_email.text.trim()),
    );
  }

  void _goToReset() {
    final email = Uri.encodeComponent(_email.text.trim());
    unawaited(context.push('${AppRoutes.resetPassword}?email=$email'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PasswordRecoveryCubit, PasswordRecoveryState>(
      builder: (context, state) {
        final sent = state.status == RecoveryStatus.emailSent;
        return BrandScaffold(
          logo: AppImages.logo,
          logoHeight: BrandScaffold.markLogoHeight,
          title: l10n.authForgotTitle,
          subtitle: sent ? null : l10n.authForgotSubtitle,
          children: sent
              ? _sentBody(context, l10n)
              : _formBody(context, l10n, state),
        );
      },
    );
  }

  List<Widget> _formBody(
    BuildContext context,
    AppLocalizations l10n,
    PasswordRecoveryState state,
  ) => [
    AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.authEmail,
              controller: _email,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              errorText: state.fieldErrors['email']?.first,
              validator: (v) => AuthValidators.email(context, v),
            ),
            if (state.status == RecoveryStatus.failure &&
                state.fieldErrors.isEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              AuthFormError(state.errorMessage ?? l10n.authFailed),
            ],
          ],
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.lg),
    AppButton(
      label: l10n.authSendResetLink,
      loading: state.isSubmitting,
      onPressed: _submit,
    ),
  ];

  List<Widget> _sentBody(BuildContext context, AppLocalizations l10n) => [
    Icon(
      Icons.mark_email_read_outlined,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    ),
    const SizedBox(height: AppSpacing.md),
    Text(
      l10n.authResetEmailSent,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
    const SizedBox(height: AppSpacing.lg),
    AppButton(label: l10n.authHaveResetCode, onPressed: _goToReset),
    const SizedBox(height: AppSpacing.sm),
    AppButton(
      label: l10n.authBackToLogin,
      variant: AppButtonVariant.text,
      onPressed: () => context.go(AppRoutes.auth),
    ),
  ];
}
