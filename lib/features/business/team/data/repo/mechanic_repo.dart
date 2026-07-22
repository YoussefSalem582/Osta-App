import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/business/team/data/model/mechanic.dart';

/// Data layer over the B2B mechanics roster; center is resolved server-side,
/// list is not paginated (plain array ordered by name).
abstract final class MechanicRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<Mechanic> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Mechanic.fromJson(e as Map<String, dynamic>))
      .toList();

  static Mechanic _parseOne(Object? data) =>
      Mechanic.fromJson(data! as Map<String, dynamic>);

  /// The whole roster, or only active/inactive rows when [active] is set.
  static Future<List<Mechanic>> index({bool? active}) async {
    final result = await _api.get<List<Mechanic>>(
      ApiEndpoints.businessMechanics,
      parse: _parseList,
      query: {'active': ?active},
    );
    return result.data;
  }

  static Future<Mechanic> create({
    required String name,
    required String specialty,
    String? phone,
    String? photo,
    bool? isActive,
  }) async {
    final result = await _api.post<Mechanic>(
      ApiEndpoints.businessMechanics,
      parse: _parseOne,
      body: {
        'name': name,
        'specialty': specialty,
        'phone': ?phone,
        'photo': ?photo,
        'is_active': ?isActive,
      },
    );
    return result.data;
  }

  /// Partial update — send only the fields being changed.
  static Future<Mechanic> update(
    Object id, {
    String? name,
    String? specialty,
    String? phone,
    String? photo,
    bool? isActive,
  }) async {
    final result = await _api.patch<Mechanic>(
      ApiEndpoints.businessMechanic(id),
      parse: _parseOne,
      body: {
        'name': ?name,
        'specialty': ?specialty,
        'phone': ?phone,
        'photo': ?photo,
        'is_active': ?isActive,
      },
    );
    return result.data;
  }

  static Future<void> destroy(Object id) =>
      _api.delete<void>(ApiEndpoints.businessMechanic(id), parse: (_) {});
}
