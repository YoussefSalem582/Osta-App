import 'package:dio/dio.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';

/// Talks to the B2B onboarding endpoints (`/business/profile`, catalog).
///
/// [ApiClient] already throws a typed `ApiException` on failure, so nothing is
/// caught here — the wizard cubit owns the try/catch.
class BusinessOnboardingRepository {
  const BusinessOnboardingRepository(this._api);

  final ApiClient _api;

  /// Step 1 — save business info + optional logo + map pin.
  ///
  /// Two transports, because PHP only parses `multipart/form-data` on POST —
  /// never on PUT. A real PUT with a multipart body leaves `$_POST`/`$_FILES`
  /// empty, and since every rule on `UpdateBusinessProfileRequest` is
  /// `sometimes`, it validates clean and saves *nothing*: 200 OK, whole profile
  /// discarded. So the logo path POSTs with `_method: PUT` (Laravel resolves
  /// the override before routing, matching the same `Route::put`); the
  /// JSON path can PUT directly, since Laravel parses JSON on any verb.
  Future<void> updateProfile(BusinessProfileInput input) async {
    final logoPath = input.logoPath;
    if (logoPath == null || logoPath.isEmpty) {
      await _api.put<Object?>(
        ApiEndpoints.businessProfile,
        body: input.toJson(),
        parse: (data) => data,
      );
      return;
    }
    final body = FormData.fromMap(<String, dynamic>{
      ...input.toJson(),
      '_method': 'PUT',
      'logo': await MultipartFile.fromFile(logoPath),
    });
    await _api.post<Object?>(
      ApiEndpoints.businessProfile,
      body: body,
      parse: (data) => data,
    );
  }

  /// Step 2 — load the 12 seeded presets (OIL / BRAKES / AC).
  Future<List<CatalogPreset>> fetchPresets() async {
    final result = await _api.get<List<CatalogPreset>>(
      ApiEndpoints.businessCatalogPresets,
      parse: (data) => (data as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CatalogPreset.fromJson)
          .toList(),
    );
    return result.data;
  }

  /// Step 2 — bulk-attach selected presets (≥1 required by the backend).
  Future<void> attachCatalog(List<String> presetIds) async {
    await _api.post<Object?>(
      ApiEndpoints.businessCatalog,
      body: {
        'items': presetIds.map((id) => {'preset_id': id}).toList(),
      },
      parse: (data) => data,
    );
  }
}
