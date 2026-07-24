part of 'shop_list_bloc.dart';

enum ShopListStatus { initial, loading, loadingMore, loaded, error }

/// One state for the paginated product grid shared by browse + seller catalog.
/// A single status field (rather than a class per phase) keeps the query /
/// category / pagination cursor alive across reloads.
class ShopListState extends Equatable {
  const ShopListState({
    this.status = ShopListStatus.initial,
    this.products = const [],
    this.query,
    this.category,
    this.page = 1,
    this.hasMore = true,
    this.message,
  });

  final ShopListStatus status;
  final List<Product> products;
  final String? query;
  final String? category;
  final int page;
  final bool hasMore;

  /// Last error message (e.g. a failed load-more that kept the current list).
  final String? message;

  ShopListState copyWith({
    ShopListStatus? status,
    List<Product>? products,
    String? query,
    bool clearQuery = false,
    String? category,
    bool clearCategory = false,
    int? page,
    bool? hasMore,
    String? message,
    bool clearMessage = false,
  }) => ShopListState(
    status: status ?? this.status,
    products: products ?? this.products,
    query: clearQuery ? null : (query ?? this.query),
    category: clearCategory ? null : (category ?? this.category),
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    message: clearMessage ? null : (message ?? this.message),
  );

  @override
  List<Object?> get props => [
    status,
    products,
    query,
    category,
    page,
    hasMore,
    message,
  ];
}
