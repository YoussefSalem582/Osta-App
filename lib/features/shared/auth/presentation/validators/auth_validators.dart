import 'package:flutter/widgets.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// How strong a candidate password is, scored by length + character-class
/// variety. Drives the register/reset strength meter (not a hard gate — the
/// [AuthValidators.password] rule is the gate).
enum PasswordStrength { weak, medium, strong }

/// Shared, localized form validators for the auth surfaces (login, register,
/// forgot/reset password). Keeping them in one place stops the same email /
/// password rules drifting apart across screens.
abstract final class AuthValidators {
  /// Pragmatic email shape: `local@domain.tld` with no spaces. Not RFC-5322
  /// (that's unbounded); the server is the source of truth, this just catches
  /// obvious typos before a round-trip.
  static final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Non-empty (after trimming). [message] overrides the generic "required"
  /// text where a field-specific prompt reads better ("Enter the brand").
  static String? requiredField(
    BuildContext context,
    String? value, {
    String? message,
  }) => (value == null || value.trim().isEmpty)
      ? (message ?? context.l10n.validationRequired)
      : null;

  /// Present and shaped like an email (`x@y.z`).
  static String? email(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.l10n.validationRequired;
    if (!_emailRe.hasMatch(v)) return context.l10n.validationEmail;
    return null;
  }

  /// Present, and — when [enforceStrength] (register / reset) — [_meetsPolicy].
  /// Login skips the strength check so legacy passwords still surface as a
  /// server 422 rather than a client block.
  static String? password(
    BuildContext context,
    String? value, {
    bool enforceStrength = true,
  }) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.validationRequired;
    if (enforceStrength && !_meetsPolicy(v)) {
      return context.l10n.validationPassword;
    }
    return null;
  }

  /// The server's rule, mirrored exactly: `Password::min(8)->mixedCase()
  /// ->numbers()`. Anything looser here blesses a password the server then
  /// 422s; anything stricter blocks one it would have accepted.
  static bool _meetsPolicy(String v) =>
      v.length >= 8 && _hasLower(v) && _hasUpper(v) && _hasDigit(v);

  /// Matches [original] exactly (confirm-password fields).
  static String? confirm(
    BuildContext context,
    String? value,
    String original,
  ) => value == original ? null : context.l10n.validationPasswordMatch;

  /// Egyptian mobile number entered after the `+20` prefix: 10 digits starting
  /// with `1` (e.g. `1012345678`). A leading `0` is tolerated and stripped by
  /// [normalizeEgyptPhone].
  static String? egyptPhone(BuildContext context, String? value) {
    final digits = _digitsOnly(value).replaceFirst(RegExp('^0'), '');
    if (digits.isEmpty) return context.l10n.validationRequired;
    if (!RegExp(r'^1[0-9]{9}$').hasMatch(digits)) {
      return context.l10n.validationPhone;
    }
    return null;
  }

  /// Normalizes a validated Egyptian mobile to E.164 (`+201XXXXXXXXX`).
  static String normalizeEgyptPhone(String value) {
    final digits = _digitsOnly(value).replaceFirst(RegExp('^0'), '');
    return '+20$digits';
  }

  /// Scores [value] for the strength meter: anything the server would reject is
  /// weak, meeting [_meetsPolicy] is medium, and extra length or a symbol on
  /// top is strong. Shares the gate so the meter can never call a password
  /// "medium" that submit then rejects. Pure, context-free.
  static PasswordStrength strength(String value) {
    if (!_meetsPolicy(value)) return PasswordStrength.weak;
    var bonus = 0;
    if (value.length >= 12) bonus++;
    if (_hasSymbol(value)) bonus++;
    return bonus >= 2 ? PasswordStrength.strong : PasswordStrength.medium;
  }

  static bool _hasDigit(String v) => RegExp('[0-9]').hasMatch(v);
  static bool _hasLower(String v) => RegExp('[a-z]').hasMatch(v);
  static bool _hasUpper(String v) => RegExp('[A-Z]').hasMatch(v);
  static bool _hasSymbol(String v) => RegExp('[^A-Za-z0-9]').hasMatch(v);

  static String _digitsOnly(String? value) =>
      (value ?? '').replaceAll(RegExp('[^0-9]'), '');
}
