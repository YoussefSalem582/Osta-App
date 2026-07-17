import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shop/data/repo/shop_repo.dart';
import 'package:osta/features/shop/presentation/cubit/my_products_state.dart';

/// The caller's own shop listings (`/me/products`) — list + delete. Create and
/// edit are self-contained in `ProductFormPage`; this cubit reloads after them.
class MyProductsCubit extends Cubit<MyProductsState> {
  MyProductsCubit() : super(const MyProductsInitial());

  Future<void> load() async {
    emit(const MyProductsLoading());
    try {
      final result = await ShopRepo.myProducts();
      emit(MyProductsLoaded(result.data));
    } on ApiException catch (e) {
      emit(MyProductsError(e.message));
    } on Object catch (e, s) {
      log('MyProductsCubit.load failed', error: e, stackTrace: s);
      emit(MyProductsError(e.toString()));
    }
  }

  Future<void> delete(Object id) async {
    emit(const MyProductsDeleteLoading());
    try {
      await ShopRepo.deleteProduct(id);
      emit(const MyProductsDeleteSuccess());
    } on ApiException catch (e) {
      emit(MyProductsDeleteError(e.message));
    } on Object catch (e, s) {
      log('MyProductsCubit.delete failed', error: e, stackTrace: s);
      emit(MyProductsDeleteError(e.toString()));
    }
  }
}
