import 'package:osta/core/session/app_role.dart';

/// Auth surface used by the presentation layer. Both calls send
/// `account_type = accountType.wireName` and return the server's authoritative
/// role (`me.type`) so the caller can self-heal a wrong-shell choice.
abstract interface class AuthRepository {
  /// `POST /auth/login`. Persists the returned token pair and returns
  /// `me.type`.
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  });

  /// `POST /auth/register`. Persists the returned token pair and returns
  /// `me.type`.
  Future<AppRole> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required AppRole accountType,
    String? phone,
  });
}
