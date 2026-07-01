/// Build flavor, selected at compile time via `--dart-define=FLAVOR=dev`.
enum AppFlavor {
  dev,
  staging,
  prod;

  /// Resolves the flavor from the `FLAVOR` dart-define, defaulting to [dev].
  static AppFlavor fromEnv() {
    const name = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return AppFlavor.values.firstWhere(
      (flavor) => flavor.name == name,
      orElse: () => AppFlavor.dev,
    );
  }
}
