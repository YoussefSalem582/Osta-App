import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/business/onboarding/data/models/custom_service_input.dart';

/// Contract for the B2B onboarding endpoints. `ApiClient` throws
/// `ApiException`; the repo doesn't catch it — the wizard cubit owns the
/// try/catch.
abstract interface class BusinessOnboardingRepository {
  /// Reads the owner's own center back (`GET /business/profile`) so a post-
  /// onboarding edit form can prefill. Mirrors `BusinessProfileResource`; the
  /// `services` relation is eager-loaded server-side.
  Future<BusinessProfile> fetchProfile();

  /// Step 1 — save business info + optional logo + map pin.
  Future<void> updateProfile(BusinessProfileInput input);

  /// Step 2 — load the 12 seeded presets (OIL / BRAKES / AC).
  Future<List<CatalogPreset>> fetchPresets();

  /// Step 2 — bulk-attach selected presets (≥1 required). Only for
  /// preset-backed services; custom ones go through [createCustomService].
  Future<void> attachCatalog(List<String> presetIds);

  /// Step 2 — add one merchant-authored service (`POST /business/services`).
  Future<void> createCustomService(CustomServiceInput input);
}
