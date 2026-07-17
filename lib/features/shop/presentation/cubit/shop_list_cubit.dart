import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shop/data/models/product.dart';
import 'package:osta/features/shop/data/repo/shop_repo.dart';
import 'package:osta/features/shop/presentation/cubit/shop_list_state.dart';

/// Where a [ShopListCubit] pulls its page from: the whole marketplace (browse)
/// or a single seller's storefront.
enum ShopSource { browse, seller }

/// Paginated product list backing both the browse grid and a seller catalog.
/// Reset-on-filter for browse; append-on-scroll for both.
class ShopListCubit extends Cubit<ShopListState> {
  ShopListCubit({
    this.source = ShopSource.browse,
    this.ownerId,
    this.isCenter = false,
  }) : super(const ShopListState());

  final ShopSource source;
  final Object? ownerId;
  final bool isCenter;

  Future<ApiResult<List<Product>>> _fetch(int page) => switch (source) {
    ShopSource.browse => ShopRepo.browse(
      query: state.query,
      category: state.category,
      page: page,
    ),
    ShopSource.seller => ShopRepo.sellerCatalog(
      ownerId: ownerId!,
      isCenter: isCenter,
      page: page,
    ),
  };

  bool _hasMore(PaginationMeta? meta) =>
      meta != null && meta.currentPage < meta.lastPage;

  /// Load (or reload) the first page with the current query/category.
  Future<void> load() async {
    emit(state.copyWith(status: ShopListStatus.loading, clearMessage: true));
    try {
      final res = await _fetch(1);
      emit(
        state.copyWith(
          status: ShopListStatus.loaded,
          products: res.data,
          page: 1,
          hasMore: _hasMore(res.meta),
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: ShopListStatus.error, message: e.message));
    } on Object catch (e, s) {
      log('ShopListCubit.load failed', error: e, stackTrace: s);
      emit(state.copyWith(status: ShopListStatus.error, message: e.toString()));
    }
  }

  /// Append the next page. No-op while already loading or past the last page.
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == ShopListStatus.loading ||
        state.status == ShopListStatus.loadingMore) {
      return;
    }
    final next = state.page + 1;
    emit(
      state.copyWith(status: ShopListStatus.loadingMore, clearMessage: true),
    );
    try {
      final res = await _fetch(next);
      emit(
        state.copyWith(
          status: ShopListStatus.loaded,
          products: [...state.products, ...res.data],
          page: next,
          hasMore: _hasMore(res.meta),
        ),
      );
    } on ApiException catch (e) {
      // Keep what we have; drop back to loaded so the grid stays usable.
      emit(state.copyWith(status: ShopListStatus.loaded, message: e.message));
    } on Object catch (e, s) {
      log('ShopListCubit.loadMore failed', error: e, stackTrace: s);
      emit(
        state.copyWith(status: ShopListStatus.loaded, message: e.toString()),
      );
    }
  }

  /// Debounced by the caller — sets the term and reloads from page 1.
  Future<void> search(String? query) {
    emit(state.copyWith(query: query, clearQuery: query == null));
    return load();
  }

  /// A null [category] means "All".
  Future<void> selectCategory(String? category) {
    emit(state.copyWith(category: category, clearCategory: category == null));
    return load();
  }
}
