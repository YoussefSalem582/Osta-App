import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

/// Loads a single product (with its owner) for the detail screen. One instance
/// per product, like `CenterDetailBloc`.
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc(this._repo, this.productId)
    : super(const ProductDetailInitial()) {
    on<ProductDetailStarted>(_onStarted);
  }

  final ShopRepository _repo;
  final Object productId;

  Future<void> _onStarted(
    ProductDetailStarted event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());
    try {
      final product = await _repo.detail(productId);
      emit(ProductDetailLoaded(product));
    } on ApiException catch (e) {
      emit(ProductDetailError(e.message));
    } on Object catch (e, s) {
      log('ProductDetailBloc.load failed', error: e, stackTrace: s);
      emit(ProductDetailError(e.toString()));
    }
  }
}
