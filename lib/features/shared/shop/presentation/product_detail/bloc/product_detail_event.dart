part of 'product_detail_bloc.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or retry) the product this bloc was constructed for.
class ProductDetailStarted extends ProductDetailEvent {
  const ProductDetailStarted();
}
