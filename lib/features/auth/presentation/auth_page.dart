import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/presentation/auth_cubit.dart';
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
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
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
          email: _email.text.trim(),
          password: _password.text,
          phone: _phone.text.trim(),
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
                        validator: (v) => _required(context, v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authLastName,
                        controller: _lastName,
                        textInputAction: TextInputAction.next,
                        validator: (v) => _required(context, v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.authPhoneOptional,
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AppTextField(
                      label: l10n.authEmail,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateEmail(context, v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.authPassword,
                      controller: _password,
                      obscureText: true,
                      obscureToggle: true,
                      validator: (v) =>
                          _validatePassword(context, v, isRegister: isRegister),
                    ),
                    if (state.status == AuthStatus.failure) ...[
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
                      onPressed: () => _submit(state),
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

  String? _required(BuildContext context, String? value) =>
      (value == null || value.trim().isEmpty)
      ? context.l10n.validationRequired
      : null;

  String? _validateEmail(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.l10n.validationRequired;
    if (!v.contains('@') || !v.contains('.')) {
      return context.l10n.validationEmail;
    }
    return null;
  }

  String? _validatePassword(
    BuildContext context,
    String? value, {
    required bool isRegister,
  }) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.validationRequired;
    if (isRegister && v.length < 8) return context.l10n.validationPassword;
    return null;
  }
}
