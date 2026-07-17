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
    this.customServices = const [],
    this.categoryFilter,
    this.fieldErrors = const {},
    this.errorMessage,
    this.networkError = false,
  });

  /// Inverse of [toDraftJson]. Unknown or malformed values fall back to the
  /// defaults rather than throwing — a bad draft must never brick the wizard.
  factory BusinessOnboardingState.fromDraftJson(Map<String, dynamic> json) =>
      BusinessOnboardingState(
        tradeName: json['trade_name'] as String? ?? '',
        legalName: json['legal_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        city: json['city'] as String? ?? '',
        addressLine: json['address_line'] as String? ?? '',
        businessType: json['business_type'] as String? ?? 'workshop',
        yearFounded: json['year_founded'] as int?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        customServices: [
          for (final s
              in (json['custom_services'] as List<dynamic>? ?? const []))
            if (s is Map<String, dynamic>) CustomServiceInput.fromJson(s),
        ],
      );

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

  /// Merchant-authored services, staged locally until Activate posts them to
  /// `/business/services` (the catalog endpoint only takes preset ids).
  final List<CustomServiceInput> customServices;

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

  /// A custom service counts: #53 requires ≥1 service in the catalog, not ≥1
  /// preset. Reading only selectedPresetIds would block a merchant who typed
  /// their own services in and picked none of the presets.
  bool get canActivate => selectedServiceCount > 0 && !isActivating;

  /// Everything the catalog would post on Activate — chosen presets plus staged
  /// custom services. Drives the count on the Activate button.
  int get selectedServiceCount =>
      selectedPresetIds.length + customServices.length;

  List<CatalogPreset> get filteredPresets {
    final filter = categoryFilter;
    if (filter == null || filter.isEmpty) return presets;
    return presets.where((p) => p.category == filter).toList();
  }

  /// Whether every currently-visible preset is already selected — the "add all"
  /// shortcut has nothing left to do, so the page hides it.
  bool get allFilteredSelected {
    final filtered = filteredPresets;
    return filtered.isNotEmpty &&
        filtered.every((p) => selectedPresetIds.contains(p.id));
  }

  /// The identity draft, for [SessionStore.writeBusinessDraft].
  ///
  /// Persists the typed answers only — not [presets]/[selectedPresetIds]
  /// (re-fetched on entering step 2) and not [logoPath].
  ///
  /// ponytail: logoPath is an image_picker cache path, which the OS may reap
  /// between launches; a restored one can point at nothing. Re-picking a logo
  /// is one tap, so it is not worth copying the file somewhere durable.
  Map<String, dynamic> toDraftJson() => {
    'trade_name': tradeName,
    'legal_name': legalName,
    'phone': phone,
    'city': city,
    'address_line': addressLine,
    'business_type': businessType,
    'year_founded': ?yearFounded,
    'latitude': ?latitude,
    'longitude': ?longitude,
    'custom_services': [
      for (final s in customServices) s.toJson(),
    ],
  };

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
    List<CustomServiceInput>? customServices,
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
    customServices: customServices ?? this.customServices,
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
    customServices,
    categoryFilter,
    fieldErrors,
    errorMessage,
    networkError,
  ];
}

const _unset = Object();
