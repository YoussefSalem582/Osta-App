import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shop/data/repo/shop_repo.dart';
import 'package:osta/features/shop/presentation/cubit/product_detail_state.dart';

/// Loads a single product (with its owner) for the detail screen.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailInitial());

  Future<void> load(Object id) async {
    emit(const ProductDetailLoading());
    try {
      final product = await ShopRepo.detail(id);
      emit(ProductDetailLoaded(product));
    } on ApiException catch (e) {
      emit(ProductDetailError(e.message));
    } on Object catch (e, s) {
      log('ProductDetailCubit.load failed', error: e, stackTrace: s);
      emit(ProductDetailError(e.toString()));
    }
  }
}
