part of 'my_products_bloc.dart';

sealed class MyProductsEvent extends Equatable {
  const MyProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the caller's own listings.
class MyProductsLoadRequested extends MyProductsEvent {
  const MyProductsLoadRequested();
}

class MyProductsDeleteRequested extends MyProductsEvent {
  const MyProductsDeleteRequested(this.id);

  final Object id;

  @override
  List<Object?> get props => [id];
}
