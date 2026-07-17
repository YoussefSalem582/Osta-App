import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// A 3-segment bar + label reflecting [AuthValidators.strength] of [password].
/// Renders nothing for an empty password (nothing to score yet).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = context.appColors;
    final theme = Theme.of(context);
    final strength = AuthValidators.strength(password);

    final (filled, color, label) = switch (strength) {
      PasswordStrength.weak => (
        1,
        theme.colorScheme.error,
        l10n.passwordStrengthWeak,
      ),
      PasswordStrength.medium => (
        2,
        colors.warning,
        l10n.passwordStrengthMedium,
      ),
      PasswordStrength.strong => (
        3,
        colors.success,
        l10n.passwordStrengthStrong,
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < filled
                          ? color
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
