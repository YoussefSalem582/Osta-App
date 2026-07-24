part of 'my_products_bloc.dart';

abstract class MyProductsState extends Equatable {
  const MyProductsState();

  @override
  List<Object?> get props => [];
}

class MyProductsInitial extends MyProductsState {
  const MyProductsInitial();
}

class MyProductsLoading extends MyProductsState {
  const MyProductsLoading();
}

class MyProductsLoaded extends MyProductsState {
  const MyProductsLoaded(this.products);

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

class MyProductsError extends MyProductsState {
  const MyProductsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Delete sub-states (list stays rendered from the page's local copy) ──

class MyProductsDeleteLoading extends MyProductsState {
  const MyProductsDeleteLoading();
}

class MyProductsDeleteSuccess extends MyProductsState {
  const MyProductsDeleteSuccess();
}

class MyProductsDeleteError extends MyProductsState {
  const MyProductsDeleteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
