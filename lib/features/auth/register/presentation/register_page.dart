import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:osta/features/auth/shared/presentation/validators/auth_validators.dart';
import 'package:osta/features/auth/shared/presentation/widgets/dial_prefix.dart';
import 'package:osta/features/auth/shared/presentation/widgets/password_strength_meter.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';
import 'package:osta/shared/ui/or_divider.dart';

/// Register entry for the chosen role. Sends `account_type = activeRole`;
/// success hands the authoritative role to the session and the router leaves
/// this screen. The username field checks availability live; "have an account"
/// navigates to login.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
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

  /// Shortest username worth a round-trip (also the server min).
  static const _minUsername = 3;

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

  /// Photo upload and social sign-in are not wired yet — same stub the
  /// auth-choose screen shows.
  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
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
          curr.status == RegisterStatus.failure && curr.fieldErrors.isEmpty,
      listener: (context, state) => AppToaster.showError(
        state.networkError
            ? context.l10n.errorNetwork
            : (state.errorMessage ?? context.l10n.authFailed),
      ),
      builder: (context, state) {
        return BrandScaffold(
          logo: AppImages.logo,
          logoHeight: BrandScaffold.markLogoHeight,
          title: l10n.authRegisterTitle,
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
    _PhotoPicker(onTap: _comingSoon),
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

/// Avatar placeholder for the (not-yet-wired) profile photo: a dashed brand
/// ring with a person glyph and a camera badge, plus a prompt below. Tapping
/// runs [onTap] — currently the "coming soon" stub.
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.onTap});

  final VoidCallback onTap;

  static const double _ring = 120;
  static const double _badge = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const green = AppColors.brandGreen;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox.square(
            dimension: _ring,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.06),
                  ),
                ),
                const CustomPaint(
                  size: Size.square(_ring),
                  painter: _DashedRingPainter(green),
                ),
                const Icon(Icons.person_outline, size: 48, color: green),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: _badge,
                    height: _badge,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: green,
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authAddPhoto,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Draws the dashed circle for [_PhotoPicker] — no `dotted_border` dependency
/// for one ring.
class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dashes = 34;
    const sweep = 2 * math.pi / dashes;
    final rect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - 1, // keep the 2px stroke inside the bounds
    );
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
