part of 'business_onboarding_cubit.dart';

enum BusinessOnboardingStatus {
  idle,
  submittingProfile,
  profileSubmitted,
  loadingPresets,
  activating,
  activated,
  failure,
}

/// Single state for the whole business onboarding wizard (identity → catalog).
class BusinessOnboardingState extends Equatable {
  const BusinessOnboardingState({
    this.status = BusinessOnboardingStatus.idle,
    this.tradeName = '',
    this.legalName = '',
    this.phone = '',
    this.city = '',
    this.addressLine = '',
    this.businessType = 'workshop',
    this.yearFounded,
    this.latitude,
    this.longitude,
    this.logoPath,
    this.presets = const [],
    this.selectedPresetIds = const {},
    this.categoryFilter,
    this.fieldErrors = const {},
    this.errorMessage,
    this.networkError = false,
  });

  final BusinessOnboardingStatus status;

  // --- Identity draft ---
  final String tradeName;
  final String legalName;
  final String phone;
  final String city;
  final String addressLine;
  final String businessType;
  final int? yearFounded;
  final double? latitude;
  final double? longitude;
  final String? logoPath;

  // --- Catalog ---
  final List<CatalogPreset> presets;
  final Set<String> selectedPresetIds;

  /// `null` = all; otherwise a wire category (`oil` / `brakes` / `ac`).
  final String? categoryFilter;

  final Map<String, List<String>> fieldErrors;
  final String? errorMessage;
  final bool networkError;

  bool get hasLocation => latitude != null && longitude != null;

  bool get isSubmittingProfile =>
      status == BusinessOnboardingStatus.submittingProfile;

  bool get isLoadingPresets =>
      status == BusinessOnboardingStatus.loadingPresets;

  bool get isActivating => status == BusinessOnboardingStatus.activating;

  bool get canActivate => selectedPresetIds.isNotEmpty && !isActivating;

  List<CatalogPreset> get filteredPresets {
    final filter = categoryFilter;
    if (filter == null || filter.isEmpty) return presets;
    return presets.where((p) => p.category == filter).toList();
  }

  BusinessOnboardingState copyWith({
    BusinessOnboardingStatus? status,
    String? tradeName,
    String? legalName,
    String? phone,
    String? city,
    String? addressLine,
    String? businessType,
    Object? yearFounded = _unset,
    Object? latitude = _unset,
    Object? longitude = _unset,
    Object? logoPath = _unset,
    List<CatalogPreset>? presets,
    Set<String>? selectedPresetIds,
    Object? categoryFilter = _unset,
    Map<String, List<String>>? fieldErrors,
    Object? errorMessage = _unset,
    bool? networkError,
  }) => BusinessOnboardingState(
    status: status ?? this.status,
    tradeName: tradeName ?? this.tradeName,
    legalName: legalName ?? this.legalName,
    phone: phone ?? this.phone,
    city: city ?? this.city,
    addressLine: addressLine ?? this.addressLine,
    businessType: businessType ?? this.businessType,
    yearFounded: identical(yearFounded, _unset)
        ? this.yearFounded
        : yearFounded as int?,
    latitude: identical(latitude, _unset) ? this.latitude : latitude as double?,
    longitude: identical(longitude, _unset)
        ? this.longitude
        : longitude as double?,
    logoPath: identical(logoPath, _unset) ? this.logoPath : logoPath as String?,
    presets: presets ?? this.presets,
    selectedPresetIds: selectedPresetIds ?? this.selectedPresetIds,
    categoryFilter: identical(categoryFilter, _unset)
        ? this.categoryFilter
        : categoryFilter as String?,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    networkError: networkError ?? this.networkError,
  );

  @override
  List<Object?> get props => [
    status,
    tradeName,
    legalName,
    phone,
    city,
    addressLine,
    businessType,
    yearFounded,
    latitude,
    longitude,
    logoPath,
    presets,
    selectedPresetIds,
    categoryFilter,
    fieldErrors,
    errorMessage,
    networkError,
  ];
}

const _unset = Object();
