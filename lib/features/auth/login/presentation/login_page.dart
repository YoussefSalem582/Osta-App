import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:osta/features/auth/shared/presentation/validators/auth_validators.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// Login entry for the chosen role. Sends `account_type = activeRole`; success
/// hands the authoritative role to the session and the router leaves this
/// screen. "Create account" navigates to the register surface.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ponytail: debug-only login prefill for the App Review / QA test account.
    // Ships nothing in release (kDebugMode is compiled out).
    if (kDebugMode) {
      _email.text = LoginBloc.debugEmail;
      _password.text = LoginBloc.debugPassword;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginBloc>().add(
      LoginSubmitted(email: _email.text.trim(), password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
          curr.status == LoginStatus.failure && curr.fieldErrors.isEmpty,
      listener: (context, state) => AppToaster.showError(
        state.networkError
            ? context.l10n.errorNetwork
            : (state.errorMessage ?? context.l10n.authFailed),
      ),
      builder: (context, state) {
        return BrandScaffold(
          logo: AppImages.logo,
          logoHeight: BrandScaffold.markLogoHeight,
          title: l10n.authSignInTitle,
          onBack: () => context.go(AppRoutes.authChoose),
          children: [
            AppCard(
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: l10n.authEmail,
                        controller: _email,
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        errorText: state.fieldErrors['email']?.first,
                        validator: (v) => AuthValidators.email(context, v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authPassword,
                        controller: _password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        obscureToggle: true,
                        autofillHints: const [AutofillHints.password],
                        errorText: state.fieldErrors['password']?.first,
                        // Login skips the strength check so legacy short
                        // passwords surface as a server 422, not a client
                        // block.
                        validator: (v) => AuthValidators.password(
                          context,
                          v,
                          enforceStrength: false,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () =>
                              unawaited(context.push(AppRoutes.forgotPassword)),
                          child: Text(l10n.authForgotPassword),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.authSubmit,
              loading: state.isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.authToRegister,
              variant: AppButtonVariant.text,
              onPressed: state.isSubmitting
                  ? null
                  : () => context.go(AppRoutes.register),
            ),
          ],
        );
      },
    );
  }
}
