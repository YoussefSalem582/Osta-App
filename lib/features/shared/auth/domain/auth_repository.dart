import 'package:osta/core/session/app_role.dart';

/// Auth surface used by the presentation layer. Both calls send
/// `account_type = accountType.wireName` and return the server's authoritative
/// role (`me.type`) so the caller can self-heal a wrong-shell choice.
abstract interface class AuthRepository {
  /// `GET /auth/check-username`. Returns whether [username] is free to claim
  /// (globally unique, soft-delete-aware). Backs the register form's live
  /// availability marker.
  Future<bool> isUsernameAvailable(String username);

  /// `POST /auth/login`. Persists the returned token pair and returns
  /// `me.type`.
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  });

  /// `POST /auth/register`. Persists the token pair and returns `me.type`.
  /// [languagePreference] drives server-sent mail (no request to read
  /// `Accept-Language` from); defaults to Arabic if omitted.
  Future<AppRole> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required AppRole accountType,
    String? phone,
    String? languagePreference,
  });

  /// `POST /me/avatar`. Uploads the image at [filePath] (jpeg/png) as the
  /// authenticated user's avatar. Requires a stored token — call after
  /// [register]/[login].
  Future<void> uploadAvatar({required String filePath});

  /// `POST /auth/logout`. Best-effort server-side token revocation; always
  /// clears the locally stored token pair, even when the request fails.
  Future<void> logout();

  /// `POST /auth/password/forgot`. Triggers the email broker to send a reset
  /// link.
  Future<void> forgotPassword({required String email});

  /// `POST /auth/password/reset`. Completes the reset with the emailed token
  /// and a new password.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  });
}
