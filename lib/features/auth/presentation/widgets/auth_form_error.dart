import 'package:flutter/material.dart';

/// Non-field form error line shown under an auth form, using the themed error
/// colour (replaces ad-hoc `TextStyle(color: colorScheme.error)`).
class AuthFormError extends StatelessWidget {
  const AuthFormError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
}
