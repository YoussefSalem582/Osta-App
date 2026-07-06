import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/network/token_pair.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/auth/domain/auth_repository.dart';

/// Talks to `/auth/*`, stores the Sanctum token pair on success, and reads the
/// authoritative role from the embedded `user.type` — the same value
/// `GET /me` returns.
///
/// Registered by hand in `configureDependencies()` — no injectable codegen.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  @override
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  }) => _authenticate('/auth/login', {
    'email': email,
    'password': password,
    'account_type': accountType.wireName,
  });

  @override
  Future<AppRole> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required AppRole accountType,
    String? phone,
  }) => _authenticate('/auth/register', {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'password': password,
    'password_confirmation': password,
    'account_type': accountType.wireName,
    if (phone != null && phone.isNotEmpty) 'phone': phone,
  });

  @override
  Future<void> logout() async {
    try {
      await _api.post<Object?>(
        '/auth/logout',
        body: const <String, dynamic>{},
        parse: (data) => data,
      );
    } on ApiException {
      // The token may already be invalid server-side; a local clear is enough.
    } finally {
      await _tokens.clear();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _api.post<Object?>(
      '/forgot-password',
      authenticated: false,
      body: {'email': email},
      parse: (data) => data,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    await _api.post<Object?>(
      '/reset-password',
      authenticated: false,
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
      parse: (data) => data,
    );
  }

  Future<AppRole> _authenticate(String path, Map<String, dynamic> body) async {
    final result = await _api.post<_AuthData>(
      path,
      authenticated: false,
      body: body,
      parse: _AuthData.fromEnvelope,
    );
    await _tokens.writeTokens(
      accessToken: result.data.tokens.accessToken,
      refreshToken: result.data.tokens.refreshToken,
    );
    return result.data.role;
  }
}

/// The auth `data` block: the Sanctum token pair plus the authoritative role
/// read from the embedded user (`user.type`).
class _AuthData {
  const _AuthData({required this.tokens, required this.role});

  factory _AuthData.fromEnvelope(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Malformed auth payload');
    }
    final user = data['user'];
    final type = user is Map<String, dynamic> ? user['type'] as String? : null;
    final role = AppRole.fromWire(type);
    if (role == null) {
      throw const ServerException('Unsupported account type');
    }
    return _AuthData(tokens: parseTokenPair(data), role: role);
  }

  final TokenPair tokens;
  final AppRole role;
}
