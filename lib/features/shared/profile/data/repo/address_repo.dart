import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/profile/data/model/address.dart';

/// Data layer over `/me/addresses` (mirrors `AddressController`). The list is
/// NOT paginated; update is PUT full-replace, so omitted keys reset to null.
abstract final class AddressRepo {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  static List<Address> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Address.fromJson(e as Map<String, dynamic>))
      .toList();

  static Address _parseOne(Object? data) =>
      Address.fromJson(data! as Map<String, dynamic>);

  static Future<List<Address>> list() async {
    final result = await _api.get<List<Address>>(
      ApiEndpoints.meAddresses,
      parse: _parseList,
    );
    return result.data;
  }

  static Future<Address> create(Map<String, dynamic> body) async {
    final result = await _api.post<Address>(
      ApiEndpoints.meAddresses,
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  static Future<Address> update(Object id, Map<String, dynamic> body) async {
    final result = await _api.put<Address>(
      ApiEndpoints.meAddress(id),
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  static Future<void> delete(Object id) =>
      _api.delete<void>(ApiEndpoints.meAddress(id), parse: (_) {});
}
