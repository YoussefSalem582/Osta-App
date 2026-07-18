import 'package:equatable/equatable.dart';

/// Form DTO for `PUT /business/profile`. JSON when [logoPath] is null, multipart otherwise.
class BusinessProfileInput extends Equatable {
  const BusinessProfileInput({
    this.tradeName,
    this.legalName,
    this.phone,
    this.city,
    this.addressLine,
    this.district,
    this.businessType,
    this.yearFounded,
    this.latitude,
    this.longitude,
    this.logoPath,
  });

  final String? tradeName;
  final String? legalName;

  /// Egyptian mobile, preferably E.164 (`+201…`).
  final String? phone;
  final String? city;
  final String? addressLine;
  final String? district;

  /// One of `workshop` / `dealership` / `mobile` / `tire_shop` / `car_wash`.
  final String? businessType;
  final int? yearFounded;
  final double? latitude;
  final double? longitude;

  /// Local file path for optional multipart `logo` upload.
  final String? logoPath;

  /// Flat map for a JSON body (no logo). Omits nulls.
  Map<String, dynamic> toJson() => {
    if (tradeName != null) 'trade_name': tradeName,
    if (legalName != null) 'legal_name': legalName,
    if (phone != null) 'phone': phone,
    if (city != null) 'city': city,
    if (addressLine != null) 'address_line': addressLine,
    if (district != null) 'district': district,
    if (businessType != null) 'business_type': businessType,
    if (yearFounded != null) 'year_founded': yearFounded,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  @override
  List<Object?> get props => [
    tradeName,
    legalName,
    phone,
    city,
    addressLine,
    district,
    businessType,
    yearFounded,
    latitude,
    longitude,
    logoPath,
  ];
}
