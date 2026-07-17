import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/widgets/photo_upload_box.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';
import 'package:osta/features/shared/auth/presentation/widgets/dial_prefix.dart';
import 'package:osta/features/shared/auth/presentation/widgets/password_strength_meter.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';
import 'package:osta/shared/ui/or_divider.dart';

/// The register form itself — identical for every role.
///
/// The backend takes only personal fields at `POST /auth/register`
/// (RegisterRequest: name, username, email, phone, password, avatar); the role
/// rides along as `account_type`, and business details are a separate
/// authenticated call. So both roles submit exactly these fields, and the
/// role-specific screens are thin wrappers over this one form.
class RegisterForm extends StatefulWidget {
  const RegisterForm({required this.title, super.key});

  /// Role-specific heading — the one thing the two register screens differ on
  /// today. Give this widget more knobs as (and only as) they diverge.
  final String title;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _acceptedTerms = false;
  Timer? _usernameDebounce;
  XFile? _photo;

  /// Shortest username worth a round-trip (also the server min).
  static const _minUsername = 3;

  /// The 422 keys this form renders inline. `RegisterRequest` can also reject
  /// `account_type`, `language_preference` and `avatar`, none of which have a
  /// field here — so anything outside this set has to reach the user as a toast
  /// or it is swallowed and submit looks like it did nothing.
  static const _renderedFieldErrors = {
    'first_name',
    'last_name',
    'username',
    'email',
    'phone',
    'password',
  };

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    setState(() {}); // refresh the marker's stale-guard against the new text
    _usernameDebounce?.cancel();
    final name = value.trim();
    if (name.length < _minUsername) return;
    _usernameDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<RegisterBloc>().add(UsernameChanged(name));
    });
  }

  /// Social sign-in is not wired yet — same stub the auth-choose screen shows.
  void _comingSoon() => AppToaster.showMessage(context.l10n.comingSoon);

  /// Pick an avatar from the gallery. Uses the system photo picker (PHPicker on
  /// iOS / Photo Picker on Android), so no gallery permission prompt is needed.
  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) setState(() => _photo = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: AuthValidators.normalizeEgyptPhone(_phone.text),
        photoPath: _photo?.path,
      ),
    );
  }

  /// The ✓/✗/spinner shown in the username field's trailing slot — only when
  /// the checked name still matches what's typed (stale-guard).
  Widget? _usernameMarker(RegisterState state) {
    final text = _username.text.trim();
    if (text.length < _minUsername || state.checkedUsername != text) {
      return null;
    }
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return switch (state.usernameStatus) {
      UsernameStatus.checking => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      UsernameStatus.available => Tooltip(
        message: l10n.authUsernameAvailable,
        child: Icon(Icons.check_circle_outline, color: colors.success),
      ),
      UsernameStatus.taken => Tooltip(
        message: l10n.authUsernameTaken,
        child: Icon(Icons.cancel_outlined, color: scheme.error),
      ),
      UsernameStatus.unknown => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<RegisterBloc, RegisterState>(
      listenWhen: (prev, curr) =>
          curr.status == RegisterStatus.failure &&
          !curr.fieldErrors.keys.any(_renderedFieldErrors.contains),
      listener: (context, state) => AppToaster.showError(
        state.networkError
            ? context.l10n.errorNetwork
            : (state.errorMessage ?? context.l10n.authFailed),
      ),
      builder: (context, state) {
        return BrandScaffold(
          logo: AppImages.logo,
          logoHeight: BrandScaffold.markLogoHeight,
          title: widget.title,
          onBack: () => context.go(AppRoutes.authChoose),
          children: [
            AppCard(
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _fields(context, l10n, state),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.authCreateAccount,
              loading: state.isSubmitting,
              onPressed: _acceptedTerms ? _submit : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            OrDivider(label: l10n.authOr),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.continueWithGoogle,
              variant: AppButtonVariant.secondary,
              icon: Icons.g_mobiledata,
              onPressed: state.isSubmitting ? null : _comingSoon,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.continueWithApple,
              variant: AppButtonVariant.secondary,
              icon: Icons.apple,
              onPressed: state.isSubmitting ? null : _comingSoon,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.authToLogin,
              variant: AppButtonVariant.text,
              onPressed: state.isSubmitting
                  ? null
                  : () => context.go(AppRoutes.login),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _fields(
    BuildContext context,
    AppLocalizations l10n,
    RegisterState state,
  ) => [
    PhotoUploadBox(
      imagePath: _photo?.path,
      onTap: () => unawaited(_pickPhoto()),
    ),
    const SizedBox(height: AppSpacing.lg),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: l10n.authFirstName,
            controller: _firstName,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            errorText: state.fieldErrors['first_name']?.first,
            validator: (v) => AuthValidators.requiredField(context, v),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            label: l10n.authLastName,
            controller: _lastName,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            errorText: state.fieldErrors['last_name']?.first,
            validator: (v) => AuthValidators.requiredField(context, v),
          ),
        ),
      ],
    ),
    const SizedBox(height: AppSpacing.md),
    AppTextField(
      label: l10n.authUsername,
      controller: _username,
      prefixIcon: Icons.alternate_email,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newUsername],
      errorText: state.fieldErrors['username']?.first,
      suffixIcon: _usernameMarker(state),
      onChanged: _onUsernameChanged,
      validator: (v) => AuthValidators.requiredField(context, v),
    ),
    const SizedBox(height: AppSpacing.md),
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
      label: l10n.authPhone,
      controller: _phone,
      prefix: const DialPrefix(),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      errorText: state.fieldErrors['phone']?.first,
      validator: (v) => AuthValidators.egyptPhone(context, v),
    ),
    const SizedBox(height: AppSpacing.md),
    AppTextField(
      label: l10n.authPassword,
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
      validator: (v) => AuthValidators.confirm(context, v, _password.text),
    ),
    const SizedBox(height: AppSpacing.sm),
    CheckboxListTile(
      value: _acceptedTerms,
      onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(l10n.authAcceptTerms),
    ),
  ];
}
