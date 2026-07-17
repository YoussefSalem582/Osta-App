import 'package:dio/dio.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_provider.dart';

class BusinessIdentityRepo {
  static Future<void> updateBusinessProfile({
    required String tradeName,
    required String legalName,
    required String phone,
    required String type,
    required String city,
    String? logoPath,
    double? latitude,
    double? longitude,
  }) async {
    final payload = <String, dynamic>{
      'trade_name': tradeName,
      'legal_name': legalName,
      'phone': phone,
      'type': type,
      'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    Object? data = payload;
    if (logoPath != null && logoPath.isNotEmpty) {
      final formData = FormData.fromMap(payload);
      formData.files.add(
        MapEntry(
          'logo',
          await MultipartFile.fromFile(logoPath),
        ),
      );
      data = formData;
    }

    final response = await DioProvider.put(
      endpoint: ApiEndpoints.businessProfile,
      data: data,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Failed to update business profile');
    }
  }
}
