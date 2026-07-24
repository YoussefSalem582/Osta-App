import 'package:osta/features/shared/profile/data/models/address.dart';

/// Contract over `/me/addresses` (mirrors `AddressController`). The list is
/// NOT paginated; update is PUT full-replace, so omitted keys reset to null.
abstract interface class AddressRepository {
  Future<List<Address>> list();

  Future<Address> create(Map<String, dynamic> body);

  Future<Address> update(Object id, Map<String, dynamic> body);

  Future<void> delete(Object id);
}
