import 'package:equatable/equatable.dart';
import 'package:osta/features/shop/data/models/product.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductDetailState {
  const ProductDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
