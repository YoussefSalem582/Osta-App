import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/password_recovery/presentation/bloc/password_recovery_bloc.dart';
import 'package:osta/features/auth/shared/presentation/validators/auth_validators.dart';
import 'package:osta/features/auth/shared/presentation/widgets/password_strength_meter.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// Step 2 of password recovery: set a new password using the emailed reset
/// code. [email] and [token] are prefilled when the screen is reached from a
/// reset link (query params); otherwise the user types them in.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({this.email, this.token, super.key});

  final String? email;
  final String? token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordRecoveryBloc>(
      create: (_) => getIt<PasswordRecoveryBloc>(),
      child: _ResetPasswordView(email: email, token: token),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({this.email, this.token});

  final String? email;
  final String? token;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  late final _token = TextEditingController(text: widget.token);
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<PasswordRecoveryBloc>().add(
      PasswordResetSubmitted(
        email: _email.text.trim(),
        token: _token.text.trim(),
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
      listenWhen: (prev, curr) =>
          curr.status == RecoveryStatus.failure && curr.fieldErrors.isEmpty,
      listener: (context, state) => AppToaster.showError(
        state.networkError
            ? context.l10n.errorNetwork
            : (state.errorMessage ?? context.l10n.authFailed),
      ),
      builder: (context, state) {
        final done = state.status == RecoveryStatus.resetSuccess;
        return BrandScaffold(
          logo: AppImages.logo,
          logoHeight: BrandScaffold.markLogoHeight,
          title: l10n.authResetTitle,
          children: done
              ? _doneBody(context, l10n)
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
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.authResetCode,
              controller: _token,
              prefixIcon: Icons.confirmation_number_outlined,
              autofillHints: const [AutofillHints.oneTimeCode],
              errorText: state.fieldErrors['token']?.first,
              validator: (v) => AuthValidators.requiredField(context, v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.authNewPassword,
              controller: _password,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              obscureToggle: true,
              autofillHints: const [AutofillHints.newPassword],
              errorText: state.fieldErrors['password']?.first,
              onChanged: (_) => setState(() {}), // refresh strength meter
              validator: (v) => AuthValidators.password(context, v),
            ),
            PasswordStrengthMeter(password: _password.text),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.authConfirmPassword,
              controller: _confirm,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              obscureToggle: true,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) =>
                  AuthValidators.confirm(context, v, _password.text),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.lg),
    AppButton(
      label: l10n.authResetSubmit,
      loading: state.isSubmitting,
      onPressed: _submit,
    ),
  ];

  List<Widget> _doneBody(BuildContext context, AppLocalizations l10n) => [
    Icon(
      Icons.lock_reset,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    ),
    const SizedBox(height: AppSpacing.md),
    Text(
      l10n.authResetSuccess,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
    const SizedBox(height: AppSpacing.lg),
    AppButton(
      label: l10n.authBackToLogin,
      onPressed: () => context.go(AppRoutes.login),
    ),
  ];
}
