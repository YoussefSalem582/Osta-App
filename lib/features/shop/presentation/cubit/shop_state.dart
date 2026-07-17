import 'package:osta/features/shop/data/Model/products/datum.dart';

abstract class ShopState {}

class InitialShopState extends ShopState {}

class ShopLoadedState extends ShopState {}

class ShopSuccessState extends ShopState {
  ShopSuccessState(this.products);

  final List<Datum> products;
}

class ShopErrorState extends ShopState {}
