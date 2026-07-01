/// Sanctum dual-token pair extracted from an auth response `data` block.
typedef TokenPair = ({String accessToken, String refreshToken});

/// Parses a token pair from envelope `data`, tolerating both the Laravel
/// snake_case keys and camelCase variants.
TokenPair parseTokenPair(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Auth response has no token data');
  }
  String read(String snake, String camel) {
    final value = data[snake] ?? data[camel];
    if (value is! String) throw FormatException('Missing $snake');
    return value;
  }

  return (
    accessToken: read('access_token', 'accessToken'),
    refreshToken: read('refresh_token', 'refreshToken'),
  );
}
