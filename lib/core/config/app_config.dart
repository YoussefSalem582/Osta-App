/// Runtime config resolved from `--dart-define` at compile time. Only the
/// base URL is configurable for now — multi-flavor support is deferred.
class AppConfig {
  AppConfig()
    : baseUrl = const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://osta.technology92.com/api/v1',
      );

  final String baseUrl;
}
