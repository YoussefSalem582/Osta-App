import 'package:osta/core/config/app_flavor.dart';

/// Runtime configuration resolved from `--dart-define` values at compile time.
///
/// Base URL points at the `/api/v1` envelope; endpoints are wired in later
/// auth/data epics.
class AppConfig {
  AppConfig()
    : baseUrl = const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://api.osta.dev/api/v1',
      ),
      flavor = AppFlavor.fromEnv();

  final String baseUrl;
  final AppFlavor flavor;
}
