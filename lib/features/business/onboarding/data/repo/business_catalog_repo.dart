import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_provider.dart';
import 'package:osta/features/business/onboarding/data/Model/servise_model/servise_model.dart';

class BusinessCatalogRepo {
  static Future<ServiseModel> listServices() async {
    final response = await DioProvider.get(
      endpoint: ApiEndpoints.businessServices,
      authenticated: false,
    );
    // --------العظيمه اللي  حلت المشكلة-------
    // print(response.statusCode);
    // print(response.data);
    if (response.statusCode == 200) {
      return ServiseModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load business services: ${response.statusCode}');
  }

  // ----------------------------------------------------------------

  static Future<void> addService({
    required String name,
    required num price,
    required int duration_minutes,
  }) async {
    final response = await DioProvider.post(
      endpoint: ApiEndpoints.businessServices,
      data: {
        'name': name,
        'price': price,
        'durationMinutes': duration_minutes,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
      // return ServiseModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to add business services: ${response.statusCode}');
  }

  // ----------------------------------------------------------------
}
