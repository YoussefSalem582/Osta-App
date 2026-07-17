import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_provider.dart';
import 'package:osta/features/business/services/data/models/promotion_model/promotions_model.dart';
import 'package:osta/features/business/services/data/models/services_model/services_model.dart';

class BusinessServicesRepo {
  static Future<ServicesModel> listServices() async {
    final response = await DioProvider.get(
      endpoint: ApiEndpoints.businessServices,
      authenticated: true,
    );
    if (response.statusCode == 200) {
      return ServicesModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load business services: ${response.statusCode}');
  }

  // ----------------------------------------------------------------

  static Future<void> addService({
    required String name,
    required int price,
    required int durationMinutes,
  }) async {
    final response = await DioProvider.post(
      endpoint: ApiEndpoints.businessServices,
      data: {
        "name": name,
        "price": price,
        "duration_minutes": durationMinutes,
      },
      authenticated: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add service");
    }
  }

  // ----------------------------------------------------------------

  static Future<void> toggleService({
    required String serviceId,
    required bool isActive,
  }) async {
    final response = await DioProvider.put(
      endpoint: ApiEndpoints.businessService(serviceId),
      data: {
        "is_active": isActive,
      },
      authenticated: true,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to toggle service");
    }
  }

  // ----------------------------------------------------------------

  static Future<PromotionsModel> listPromotions() async {
    final response = await DioProvider.get(
      endpoint: ApiEndpoints.businessPromotions,
      authenticated: true,
    );
    if (response.statusCode == 200) {
      return PromotionsModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(
      'Failed to load business promotions: ${response.statusCode}',
    );
  }

  // ----------------------------------------------------------------

  static Future<void> addPromotion({
    required String title,
    required String subtitle,
    required int discountPercentage,
  }) async {
    final response = await DioProvider.post(
      endpoint: ApiEndpoints.businessPromotions,
      data: {
        "title": title,
        "subtitle": subtitle,
        "discount_percentage": discountPercentage,
      },
      authenticated: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add promotion");
    }
  }
}
