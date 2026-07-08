/// Runtime configuration resolved from `--dart-define` at compile time.
///
/// Only the API base URL is configurable for now — multi-flavor
/// (dev/staging/prod) support is deferred; see docs/ROADMAP.md. Base URL
/// points at the `/api/v1` envelope; endpoints are wired in later auth/data
/// epics.
class AppConfig {
  AppConfig()
    : baseUrl = const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://osta.technology92.com/api/v1',
      );

  final String baseUrl;
}
