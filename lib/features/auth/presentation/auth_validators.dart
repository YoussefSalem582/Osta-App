import 'package:flutter/widgets.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Shared, localized form validators for the auth surfaces (login, register,
/// forgot/reset password). Keeping them in one place stops the same email /
/// password rules drifting apart across screens.
abstract final class AuthValidators {
  /// Non-empty (after trimming).
  static String? requiredField(BuildContext context, String? value) =>
      (value == null || value.trim().isEmpty)
      ? context.l10n.validationRequired
      : null;

  /// Present and shaped like an email (`x@y.z`).
  static String? email(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.l10n.validationRequired;
    if (!v.contains('@') || !v.contains('.')) {
      return context.l10n.validationEmail;
    }
    return null;
  }

  /// Present, and — when [enforceStrength] — at least 8 characters (register /
  /// reset). Login skips the strength check so legacy short passwords still
  /// surface as a server 422 rather than a client block.
  static String? password(
    BuildContext context,
    String? value, {
    bool enforceStrength = true,
  }) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.validationRequired;
    if (enforceStrength && v.length < 8) {
      return context.l10n.validationPassword;
    }
    return null;
  }

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
    final digits = _digitsOnly(value).replaceFirst(RegExp(r'^0'), '');
    if (digits.isEmpty) return context.l10n.validationRequired;
    if (!RegExp(r'^1[0-9]{9}$').hasMatch(digits)) {
      return context.l10n.validationPhone;
    }
    return null;
  }

  /// Normalizes a validated Egyptian mobile to E.164 (`+201XXXXXXXXX`).
  static String normalizeEgyptPhone(String value) {
    final digits = _digitsOnly(value).replaceFirst(RegExp(r'^0'), '');
    return '+20$digits';
  }

  static String _digitsOnly(String? value) =>
      (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
}
