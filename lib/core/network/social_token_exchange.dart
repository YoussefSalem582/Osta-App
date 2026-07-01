import 'package:injectable/injectable.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/token_pair.dart';

/// Exchanges a Google/Apple provider token for Sanctum dual tokens and
/// persists them. The social-login UI epics (#35/#36) call this and then read
/// the stored session — no token plumbing in screens.
@lazySingleton
class SocialTokenExchange {
  SocialTokenExchange(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  /// [provider] is the backend route segment (`google` or `apple`).
  Future<void> exchange({
    required String provider,
    required String providerToken,
  }) async {
    final result = await _api.post(
      '/auth/social/$provider',
      body: {'token': providerToken},
      authenticated: false,
      parse: parseTokenPair,
    );
    await _tokens.writeTokens(
      accessToken: result.data.accessToken,
      refreshToken: result.data.refreshToken,
    );
  }
}
