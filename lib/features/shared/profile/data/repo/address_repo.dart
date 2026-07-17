import 'package:get_it/get_it.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/profile/data/model/address.dart';

/// Thin data layer over the B2C `/me/addresses` endpoints. Static methods like
/// the other features (`ShopRepo`); errors bubble as the typed `ApiException`.
///
/// Mirrors `AddressController` + `AddressResource`. The list is NOT paginated
/// (`data` is a plain array). Create/update send the snake_case FormRequest
/// keys (`label` required; the rest nullable) as a raw body — full-replace on
/// update (PUT), so omitted optional keys reset to null server-side.
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
