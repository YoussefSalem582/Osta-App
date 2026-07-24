import 'package:dio/dio.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/business/onboarding/data/models/custom_service_input.dart';
import 'package:osta/features/business/onboarding/domain/business_onboarding_repository.dart';

/// Talks to the B2B onboarding endpoints. [ApiClient] throws `ApiException`;
/// this repo doesn't catch it — the wizard cubit owns the try/catch.
class BusinessOnboardingRepositoryImpl implements BusinessOnboardingRepository {
  const BusinessOnboardingRepositoryImpl(this._api);

  final ApiClient _api;

  /// Reads the owner's own center back (`GET /business/profile`) so a post-
  /// onboarding edit form can prefill. Mirrors `BusinessProfileResource`; the
  /// `services` relation is eager-loaded server-side.
  @override
  Future<BusinessProfile> fetchProfile() async {
    final result = await _api.get<BusinessProfile>(
      ApiEndpoints.businessProfile,
      parse: (data) => BusinessProfile.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// Step 1 — save business info + optional logo + map pin.
  /// Logo path POSTs with `_method: PUT` (PHP only parses multipart on POST;
  /// a real PUT here would silently validate clean and save nothing); JSON
  /// path PUTs directly.
  @override
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
  @override
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

  /// Step 2 — bulk-attach selected presets (≥1 required). Only for
  /// preset-backed services; custom ones go through [createCustomService].
  @override
  Future<void> attachCatalog(List<String> presetIds) async {
    await _api.post<Object?>(
      ApiEndpoints.businessCatalog,
      body: {
        'items': presetIds.map((id) => {'preset_id': id}).toList(),
      },
      parse: (data) => data,
    );
  }

  /// Step 2 — add one merchant-authored service (`POST /business/services`).
  @override
  Future<void> createCustomService(CustomServiceInput input) async {
    await _api.post<Object?>(
      ApiEndpoints.businessServices,
      body: input.toJson(),
      parse: (data) => data,
    );
  }
}
