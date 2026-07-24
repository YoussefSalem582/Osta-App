import 'package:equatable/equatable.dart';

/// Identifies one seller's storefront. Passed to `SellerCatalogPage` as
/// go_router `extra`, and to `ShopListBloc` to switch it from the marketplace
/// feed to that seller's products.
class SellerCatalogArgs extends Equatable {
  const SellerCatalogArgs({
    required this.ownerId,
    required this.isCenter,
    this.ownerName,
  });

  final String ownerId;

  /// The owner is polymorphic: a ServiceCenter when true, a personal User shop
  /// when false. Decides which storefront endpoint is read.
  final bool isCenter;

  final String? ownerName;

  @override
  List<Object?> get props => [ownerId, isCenter, ownerName];
}
