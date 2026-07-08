import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/auth/shared/domain/auth_repository.dart';

/// In-memory [TokenStorage] — no platform channels in tests.
class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage() : super(const FlutterSecureStorage());

  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

/// No-op [AuthRepository] for wiring tests. Records `logout()` calls and echoes
/// the requested account type as the authoritative role.
class FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

  @override
  Future<void> uploadAvatar({required String filePath}) async {}

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  }) async => accountType;

  @override
  Future<AppRole> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required AppRole accountType,
    String? phone,
  }) async => accountType;

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {}
}

/// [HttpClientAdapter] that replays a scripted list of responses in order and
/// records every request — lets a test assert exact call sequences
/// (401 → refresh → replay) across the main and refresh Dio clients.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this._script);

  final List<ResponseBody Function(RequestOptions options)> _script;
  final List<RequestOptions> requests = [];
  final List<Object?> bodies = [];
  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    bodies.add(options.data);
    return _script[_index++](options);
  }

  @override
  void close({bool force = false}) {}
}

/// JSON [ResponseBody] helper for [ScriptedAdapter] scripts.
ResponseBody jsonResponse(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Success envelope carrying a Sanctum token pair.
Map<String, dynamic> tokenEnvelope(String access, String refresh) => {
  'success': true,
  'data': {'access_token': access, 'refresh_token': refresh},
};
