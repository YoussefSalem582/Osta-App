part of 'shop_list_bloc.dart';

sealed class ShopListEvent extends Equatable {
  const ShopListEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the first page with the current query/category. Also the
/// retry and pull-to-refresh event.
class ShopListStarted extends ShopListEvent {
  const ShopListStarted();
}

/// Append the next page. No-op while already loading or past the last page.
class ShopListMoreRequested extends ShopListEvent {
  const ShopListMoreRequested();
}

/// Debounced by the caller — sets the term and reloads from page 1.
class ShopListSearchChanged extends ShopListEvent {
  const ShopListSearchChanged(this.query);

  final String? query;

  @override
  List<Object?> get props => [query];
}

/// A null [category] means "All".
class ShopListCategorySelected extends ShopListEvent {
  const ShopListCategorySelected(this.category);

  final String? category;

  @override
  List<Object?> get props => [category];
}
