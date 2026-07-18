import 'package:osta/core/di/injection.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/onboarding/data/Model/servise_model/datum.dart';

class BusinessCatalogRepo {
  static Future<List<Datum>> listServices() async {
    final result = await getIt<ApiClient>().get<List<Datum>>(
      ApiEndpoints.businessServices,
      parse: (dynamic json) {
        if (json is List) {
          return json
              .map((e) => Datum.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return result.data;
  }

  // ----------------------------------------------------------------

  static Future<void> addService({
    required String name,
    required int price,
    required int durationMinutes,
  }) async {
    await getIt<ApiClient>().post<void>(
      ApiEndpoints.businessServices,
      body: {
        "name": name,
        "price": price,
        "duration_minutes": durationMinutes,
      },
      parse: (_) {},
    );
  }

  // ----------------------------------------------------------------
}
