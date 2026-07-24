import 'package:osta/features/shared/profile/data/models/profile_response/data.dart';
import 'package:osta/features/shared/profile/data/models/profile_response/profile_response.dart';

/// Contract for `GET/PUT /me` + avatar/delete. Reads are cache-then-network;
/// writes are online-only and write through to the cache.
abstract interface class ProfileRepository {
  /// The locally cached profile for an instant first paint, or `null`.
  Data? get cachedProfile;

  /// When [cachedProfile] was stored, for the "last updated" affordance.
  DateTime? get cachedAt;

  /// `GET /me`. Writes through to the cache on success. Rethrows the typed
  /// ApiException (notably NetworkException when offline) so the cubit can
  /// fall back to the cache instead of a blank error.
  Future<ProfileResponse> getProfile();

  Future<ProfileResponse?> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
  });

  Future<ProfileResponse?> uploadAvatar(String filePath);

  Future<void> deleteAccount();
}
