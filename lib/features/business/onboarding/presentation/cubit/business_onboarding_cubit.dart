import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/business/onboarding/data/models/custom_service_input.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';

part 'business_onboarding_state.dart';

/// Drives the post-auth business onboarding wizard (identity → catalog).
///
/// Registered as a factory in `configureDependencies()`; one instance is
/// provided for the whole wizard stack so identity draft survives into catalog.
class BusinessOnboardingCubit extends Cubit<BusinessOnboardingState> {
  BusinessOnboardingCubit(this._repo, this._store) : super(_restore(_store));

  final BusinessOnboardingRepository _repo;
  final SessionStore _store;

  /// The persisted draft, or a blank wizard. A corrupt draft is discarded
  /// rather than thrown: the wizard is mandatory, so failing to parse it would
  /// leave a merchant unable to get past step 1 at all.
  static BusinessOnboardingState _restore(SessionStore store) {
    final raw = store.businessDraft;
    if (raw == null || raw.isEmpty) return const BusinessOnboardingState();
    try {
      return BusinessOnboardingState.fromDraftJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return const BusinessOnboardingState();
    }
  }

  /// Persists on every change rather than at each step boundary — the wizard is
  /// mandatory and the app can be killed anywhere in it.
  ///
  /// Hooks [onChange] rather than listening to `stream`: onChange runs inside
  /// emit, so it is ordered against [activate]'s clear. A stream listener
  /// delivers on a later microtask and would rewrite the draft *after* it.
  @override
  void onChange(Change<BusinessOnboardingState> change) {
    super.onChange(change);
    final next = change.nextState;
    // Once Activate is under way the draft is about to be cleared for good.
    if (next.status == BusinessOnboardingStatus.activating ||
        next.status == BusinessOnboardingStatus.activated) {
      return;
    }
    unawaited(_store.writeBusinessDraft(jsonEncode(next.toDraftJson())));
  }

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

  void updateYearFounded(int value) => emit(state.copyWith(yearFounded: value));

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

  /// Selects every preset visible under the current category filter, unioned
  /// into the existing selection (the "add all" shortcut). Unioning — not
  /// replacing — respects the active chip and keeps picks from other
  /// categories, so tapping it while "Oils" is showing adds the oils and
  /// touches nothing else.
  void selectFilteredPresets() {
    emit(
      state.copyWith(
        selectedPresetIds: {
          ...state.selectedPresetIds,
          for (final p in state.filteredPresets) p.id,
        },
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
      // Nothing pre-selected: #53 requires the merchant to actively add at
      // least one service, and pre-selecting everything made canActivate true
      // on arrival, so the guard never fired. The "add all" CTA is still the
      // one-tap path for anyone who wants the full set.
      emit(
        state.copyWith(
          status: BusinessOnboardingStatus.idle,
          presets: presets,
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

  /// Adds a merchant-authored service to the local draft. Posted on [activate],
  /// not now, so a half-finished wizard leaves nothing behind on the server.
  void addCustomService(CustomServiceInput service) => emit(
    state.copyWith(customServices: [...state.customServices, service]),
  );

  void removeCustomService(int index) {
    final next = [...state.customServices]..removeAt(index);
    emit(state.copyWith(customServices: next));
  }

  /// Step 2 Activate — presets to `POST /business/catalog`, custom services to
  /// `POST /business/services`. Two endpoints because the catalog one only
  /// accepts ids of existing `catalog_presets` rows.
  Future<void> activate() async {
    if (!state.canActivate) return;
    emit(
      state.copyWith(
        status: BusinessOnboardingStatus.activating,
        errorMessage: null,
        networkError: false,
      ),
    );
    try {
      // Skipped when empty: `items` is `required|array|min:1`, so posting an
      // empty list would 422 a merchant who only added custom services.
      if (state.selectedPresetIds.isNotEmpty) {
        await _repo.attachCatalog(state.selectedPresetIds.toList());
      }
      for (final service in state.customServices) {
        await _repo.createCustomService(service);
      }
      // The center is live now, so the draft has served its purpose.
      await _store.clearBusinessDraft();
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
