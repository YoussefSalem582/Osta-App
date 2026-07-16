import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';

part 'business_onboarding_state.dart';

/// Drives the post-auth business onboarding wizard (identity → catalog).
///
/// Registered as a factory in `configureDependencies()`; one instance is
/// provided for the whole wizard stack so identity draft survives into catalog.
class BusinessOnboardingCubit extends Cubit<BusinessOnboardingState> {
  BusinessOnboardingCubit(this._repo) : super(const BusinessOnboardingState());

  final BusinessOnboardingRepository _repo;

  void updateTradeName(String value) =>
      emit(state.copyWith(tradeName: value, fieldErrors: const {}));

  void updateLegalName(String value) => emit(state.copyWith(legalName: value));

  void updatePhone(String value) =>
      emit(state.copyWith(phone: value, fieldErrors: const {}));

  void updateCity(String value) => emit(state.copyWith(city: value));

  void updateAddressLine(String value) =>
      emit(state.copyWith(addressLine: value));

  void updateBusinessType(String value) =>
      emit(state.copyWith(businessType: value));

  void setLogoPath(String? path) => emit(state.copyWith(logoPath: path));

  void setLocation(GeoPoint point) => emit(
    state.copyWith(
      latitude: point.lat,
      longitude: point.lng,
      fieldErrors: const {},
    ),
  );

  void setCategoryFilter(String? category) =>
      emit(state.copyWith(categoryFilter: category));

  void togglePreset(String id) {
    final next = Set<String>.from(state.selectedPresetIds);
    if (!next.add(id)) next.remove(id);
    emit(state.copyWith(selectedPresetIds: next));
  }

  /// Selects every loaded preset (the "Add 12 common" CTA).
  void selectAllPresets() {
    emit(
      state.copyWith(
        selectedPresetIds: state.presets.map((p) => p.id).toSet(),
      ),
    );
  }

  /// Step 1 Continue — `PUT /business/profile`.
  Future<void> submitProfile() async {
    emit(
      state.copyWith(
        status: BusinessOnboardingStatus.submittingProfile,
        fieldErrors: const {},
        errorMessage: null,
        networkError: false,
      ),
    );
    try {
      final phone = AuthValidators.normalizeEgyptPhone(state.phone);
      await _repo.updateProfile(
        BusinessProfileInput(
          tradeName: state.tradeName.trim(),
          legalName: state.legalName.trim().isEmpty
              ? null
              : state.legalName.trim(),
          phone: phone,
          city: state.city.trim().isEmpty ? null : state.city.trim(),
          addressLine: state.addressLine.trim().isEmpty
              ? null
              : state.addressLine.trim(),
          businessType: state.businessType,
          yearFounded: state.yearFounded,
          latitude: state.latitude,
          longitude: state.longitude,
          logoPath: state.logoPath,
        ),
      );
      emit(state.copyWith(status: BusinessOnboardingStatus.profileSubmitted));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          fieldErrors: e.fieldErrors,
          errorMessage: e.message,
        ),
      );
    } on NetworkException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          networkError: true,
          errorMessage: e.message,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Step 2 entry — `GET /business/catalog/presets`.
  Future<void> loadPresets() async {
    if (state.presets.isNotEmpty) return;
    emit(
      state.copyWith(
        status: BusinessOnboardingStatus.loadingPresets,
        errorMessage: null,
        networkError: false,
      ),
    );
    try {
      final presets = await _repo.fetchPresets();
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.idle,
          presets: presets,
          // Pre-select all so Activate is ready; user can deselect.
          selectedPresetIds: presets.map((p) => p.id).toSet(),
        ),
      );
    } on NetworkException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          networkError: true,
          errorMessage: e.message,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Step 2 Activate — `POST /business/catalog` with selected presets.
  Future<void> activate() async {
    if (state.selectedPresetIds.isEmpty) return;
    emit(
      state.copyWith(
        status: BusinessOnboardingStatus.activating,
        errorMessage: null,
        networkError: false,
      ),
    );
    try {
      await _repo.attachCatalog(state.selectedPresetIds.toList());
      emit(state.copyWith(status: BusinessOnboardingStatus.activated));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          fieldErrors: e.fieldErrors,
          errorMessage: e.message,
        ),
      );
    } on NetworkException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          networkError: true,
          errorMessage: e.message,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Clears one-shot navigation statuses after the UI has reacted.
  void acknowledgeNavigation() {
    if (state.status == BusinessOnboardingStatus.profileSubmitted ||
        state.status == BusinessOnboardingStatus.activated) {
      emit(state.copyWith(status: BusinessOnboardingStatus.idle));
    }
  }
}
