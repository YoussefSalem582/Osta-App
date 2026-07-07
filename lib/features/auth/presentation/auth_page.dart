import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/presentation/auth_cubit.dart';
import 'package:osta/features/auth/presentation/auth_validators.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';

/// Auth entry for the chosen role. Login and register both send
/// `account_type = activeRole`; success hands the authoritative role to the
/// session and the router leaves this screen.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isRegister = state.mode == AuthMode.register;
            final canSubmit = !isRegister || _acceptedTerms;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isRegister
                          ? l10n.authRegisterTitle
                          : l10n.authSignInTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (isRegister) ...[
                      AppTextField(
                        label: l10n.authFirstName,
                        controller: _firstName,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            AuthValidators.requiredField(context, v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authLastName,
                        controller: _lastName,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            AuthValidators.requiredField(context, v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authUsername,
                        controller: _username,
                        textInputAction: TextInputAction.next,
                        errorText: state.fieldErrors['username']?.first,
                        validator: (v) =>
                            AuthValidators.requiredField(context, v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AppTextField(
                      label: l10n.authEmail,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: state.fieldErrors['email']?.first,
                      validator: (v) => AuthValidators.email(context, v),
                    ),
                    if (isRegister) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authPhone,
                        controller: _phone,
                        prefixText: '+20 ',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        errorText: state.fieldErrors['phone']?.first,
                        validator: (v) => AuthValidators.egyptPhone(context, v),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.authPassword,
                      controller: _password,
                      obscureText: true,
                      obscureToggle: true,
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
                        obscureText: true,
                        obscureToggle: true,
                        validator: (v) =>
                            AuthValidators.confirm(context, v, _password.text),
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
                          onPressed: () =>
                              unawaited(context.push(AppRoutes.forgotPassword)),
                          child: Text(l10n.authForgotPassword),
                        ),
                      ),
                    if (state.status == AuthStatus.failure &&
                        state.fieldErrors.isEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.errorMessage ?? l10n.authFailed,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.authSubmit,
                      loading: state.isSubmitting,
                      onPressed: canSubmit ? () => _submit(state) : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: isRegister
                          ? l10n.authToLogin
                          : l10n.authToRegister,
                      variant: AppButtonVariant.text,
                      onPressed: state.isSubmitting
                          ? null
                          : context.read<AuthCubit>().toggleMode,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
