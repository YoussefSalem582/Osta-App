import 'package:flutter/material.dart';

/// App-wide toaster — shows a `SnackBar` over the root [ScaffoldMessenger].
///
/// Works from anywhere (including code without a `Scaffold` context) via
/// [messengerKey], which is wired into `MaterialApp.scaffoldMessengerKey`.
abstract final class AppToaster {
  /// Wire into `MaterialApp.scaffoldMessengerKey`.
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Error-styled toast (e.g. a failed request / network error).
  static void showError(String message) => _show(message, error: true);

  /// Neutral toast.
  static void showMessage(String message) => _show(message);

  static void _show(String message, {bool error = false}) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    final context = messengerKey.currentContext;
    final scheme = context == null ? null : Theme.of(context).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: error && scheme != null
                ? TextStyle(color: scheme.onErrorContainer)
                : null,
          ),
          backgroundColor: error ? scheme?.errorContainer : null,
        ),
      );
  }
}
