import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';
import 'package:osta/features/shared/shop/presentation/seller_catalog/seller_catalog_args.dart';

part 'shop_list_event.dart';
part 'shop_list_state.dart';

/// Paginated product list backing both the browse grid and a seller catalog:
/// a null [seller] reads the whole marketplace, otherwise that storefront.
/// Reset-on-filter for browse; append-on-scroll for both.
class ShopListBloc extends Bloc<ShopListEvent, ShopListState> {
  ShopListBloc(this._repo, {this.seller}) : super(const ShopListState()) {
    on<ShopListStarted>(_onStarted);
    on<ShopListMoreRequested>(_onMoreRequested);
    on<ShopListSearchChanged>(_onSearchChanged);
    on<ShopListCategorySelected>(_onCategorySelected);
  }

  final ShopRepository _repo;

  /// Null for the marketplace feed; set for one seller's storefront.
  final SellerCatalogArgs? seller;

  Future<ApiResult<List<Product>>> _fetch(int page) {
    final owner = seller;
    if (owner == null) {
      return _repo.browse(
        query: state.query,
        category: state.category,
        page: page,
      );
    }
    return _repo.sellerCatalog(
      ownerId: owner.ownerId,
      isCenter: owner.isCenter,
      page: page,
    );
  }

  bool _hasMore(PaginationMeta? meta) =>
      meta != null && meta.currentPage < meta.lastPage;

  Future<void> _onStarted(ShopListStarted event, Emitter<ShopListState> emit) =>
      _load(emit);

  Future<void> _load(Emitter<ShopListState> emit) async {
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
      log('ShopListBloc.load failed', error: e, stackTrace: s);
      emit(state.copyWith(status: ShopListStatus.error, message: e.toString()));
    }
  }

  Future<void> _onMoreRequested(
    ShopListMoreRequested event,
    Emitter<ShopListState> emit,
  ) async {
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
      log('ShopListBloc.loadMore failed', error: e, stackTrace: s);
      emit(
        state.copyWith(status: ShopListStatus.loaded, message: e.toString()),
      );
    }
  }

  Future<void> _onSearchChanged(
    ShopListSearchChanged event,
    Emitter<ShopListState> emit,
  ) {
    emit(state.copyWith(query: event.query, clearQuery: event.query == null));
    return _load(emit);
  }

  Future<void> _onCategorySelected(
    ShopListCategorySelected event,
    Emitter<ShopListState> emit,
  ) {
    emit(
      state.copyWith(
        category: event.category,
        clearCategory: event.category == null,
      ),
    );
    return _load(emit);
  }
}
