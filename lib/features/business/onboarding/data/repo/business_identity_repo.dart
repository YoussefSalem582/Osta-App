import 'package:dio/dio.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';

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

    await getIt<ApiClient>().put<void>(
      ApiEndpoints.businessProfile,
      body: data,
      parse: (_) {},
    );
  }
}
