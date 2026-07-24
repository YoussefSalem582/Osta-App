import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/features/shared/profile/data/models/address.dart';
import 'package:osta/features/shared/profile/domain/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._api);

  final ApiClient _api;

  static List<Address> _parseList(Object? data) => (data! as List<dynamic>)
      .map((e) => Address.fromJson(e as Map<String, dynamic>))
      .toList();

  static Address _parseOne(Object? data) =>
      Address.fromJson(data! as Map<String, dynamic>);

  @override
  Future<List<Address>> list() async {
    final result = await _api.get<List<Address>>(
      ApiEndpoints.meAddresses,
      parse: _parseList,
    );
    return result.data;
  }

  @override
  Future<Address> create(Map<String, dynamic> body) async {
    final result = await _api.post<Address>(
      ApiEndpoints.meAddresses,
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<Address> update(Object id, Map<String, dynamic> body) async {
    final result = await _api.put<Address>(
      ApiEndpoints.meAddress(id),
      body: body,
      parse: _parseOne,
    );
    return result.data;
  }

  @override
  Future<void> delete(Object id) =>
      _api.delete<void>(ApiEndpoints.meAddress(id), parse: (_) {});
}
