import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for the Sanctum access/refresh tokens.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _activeRoleKey = 'active_role';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readActiveRole() => _storage.read(key: _activeRoleKey);

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> writeActiveRole(String role) async {
    await _storage.write(key: _activeRoleKey, value: role);
  }

  Future<void> deleteActiveRole() async {
    await _storage.delete(key: _activeRoleKey);
  }

  Future<void> clear() => _storage.deleteAll();
}
