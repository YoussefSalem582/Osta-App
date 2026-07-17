import 'package:equatable/equatable.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class InitialShopState extends ShopState {
  const InitialShopState();
}

class ShopLoadedState extends ShopState {
  const ShopLoadedState();
}

class ShopLoadingState extends ShopLoadedState {
  const ShopLoadingState();
}

class ShopSuccessState extends ShopState {
  const ShopSuccessState(this.products);

  final List<Datum> products;

  @override
  List<Object?> get props => [products];
}

class ShopErrorState extends ShopState {
  const ShopErrorState([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}
