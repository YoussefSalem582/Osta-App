import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/customer/map/data/models/center_detail.dart';
import 'package:osta/features/customer/map/domain/center_detail_repository.dart';

class CenterDetailRepositoryImpl implements CenterDetailRepository {
  const CenterDetailRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<CenterDetail> detail(Object id) async {
    final result = await _api.get<CenterDetail>(
      ApiEndpoints.center(id),
      parse: (data) => CenterDetail.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  @override
  Future<CenterAvailability> availability(
    Object id, {
    required String date,
  }) async {
    final result = await _api.get<CenterAvailability>(
      ApiEndpoints.centerAvailability(id),
      query: {'date': date},
      parse: (data) =>
          CenterAvailability.fromJson(data! as Map<String, dynamic>),
    );
    return result.data;
  }

  @override
  Future<List<CenterService>> services(Object id) async {
    final result = await _api.get<List<CenterService>>(
      ApiEndpoints.centerServices(id),
      parse: (data) => (data as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CenterService.fromJson)
          .toList(),
    );
    return result.data;
  }
}
