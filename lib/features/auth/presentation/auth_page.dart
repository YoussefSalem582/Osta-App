import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/presentation/auth_cubit.dart';
import 'package:osta/features/auth/presentation/auth_validators.dart';
import 'package:osta/features/auth/presentation/widgets/auth_form_error.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// Auth entry for the chosen role. Login and register both send
/// `account_type = activeRole`; success hands the authoritative role to the
/// session and the router leaves this screen. The initial mode comes from the
/// auth-choose landing via `?mode=login|register` (defaults to login); the
/// in-page toggle still flips between the two.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modeParam = GoRouterState.of(context).uri.queryParameters['mode'];
    final mode = modeParam == 'register' ? AuthMode.register : AuthMode.login;
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>()..setMode(mode),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    // ponytail: debug-only login prefill for the App Review / QA test account.
    // Ships nothing in release (kDebugMode is compiled out).
    if (kDebugMode) {
      _email.text = 'test@osta.com';
      _password.text = 'osta123123';
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit(AuthState state) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<AuthCubit>();
    if (state.mode == AuthMode.login) {
      unawaited(
        cubit.login(email: _email.text.trim(), password: _password.text),
      );
    } else {
      unawaited(
        cubit.register(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phone: AuthValidators.normalizeEgyptPhone(_phone.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isRegister = state.mode == AuthMode.register;
        final canSubmit = !isRegister || _acceptedTerms;
        return BrandScaffold(
          logo: AppImages.logo,
          logoHeight: BrandScaffold.markLogoHeight,
          title: isRegister ? l10n.authRegisterTitle : l10n.authSignInTitle,
          // Back to the login/register chooser (both live in the auth surface).
          onBack: () => context.go(AppRoutes.authChoose),
          children: [
            AppCard(
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isRegister) ...[
                        AppTextField(
                          label: l10n.authFirstName,
                          controller: _firstName,
                          prefixIcon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                          validator: (v) =>
                              AuthValidators.requiredField(context, v),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: l10n.authLastName,
                          controller: _lastName,
                          prefixIcon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          validator: (v) =>
                              AuthValidators.requiredField(context, v),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: l10n.authUsername,
                          controller: _username,
                          prefixIcon: Icons.alternate_email,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newUsername],
                          errorText: state.fieldErrors['username']?.first,
                          validator: (v) =>
                              AuthValidators.requiredField(context, v),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
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
                      if (isRegister) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: l10n.authPhone,
                          controller: _phone,
                          prefix: const _DialPrefix(),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.telephoneNumberNational,
                          ],
                          errorText: state.fieldErrors['phone']?.first,
                          validator: (v) =>
                              AuthValidators.egyptPhone(context, v),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authPassword,
                        controller: _password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        obscureToggle: true,
                        autofillHints: [
                          if (isRegister)
                            AutofillHints.newPassword
                          else
                            AutofillHints.password,
                        ],
                        errorText: state.fieldErrors['password']?.first,
                        validator: (v) => AuthValidators.password(
                          context,
                          v,
                          enforceStrength: isRegister,
                        ),
                      ),
                      if (isRegister) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: l10n.authConfirmPassword,
                          controller: _confirm,
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          obscureToggle: true,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (v) => AuthValidators.confirm(
                            context,
                            v,
                            _password.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(l10n.authAcceptTerms),
                        ),
                      ],
                      if (!isRegister)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () => unawaited(
                              context.push(AppRoutes.forgotPassword),
                            ),
                            child: Text(l10n.authForgotPassword),
                          ),
                        ),
                      if (state.status == AuthStatus.failure &&
                          state.fieldErrors.isEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        AuthFormError(state.errorMessage ?? l10n.authFailed),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.authSubmit,
              loading: state.isSubmitting,
              onPressed: canSubmit ? () => _submit(state) : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: isRegister ? l10n.authToLogin : l10n.authToRegister,
              variant: AppButtonVariant.text,
              onPressed: state.isSubmitting
                  ? null
                  : context.read<AuthCubit>().toggleMode,
            ),
          ],
        );
      },
    );
  }
}

/// Always-visible `+20` dial-code prefix for the Egyptian phone field, with a
/// divider separating it from the input.
class _DialPrefix extends StatelessWidget {
  const _DialPrefix();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('+20', style: theme.textTheme.bodyLarge),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}
