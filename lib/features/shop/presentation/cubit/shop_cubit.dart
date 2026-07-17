import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/data/repo/shop_repo.dart';
import 'package:osta/features/shop/presentation/cubit/shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(const InitialShopState());

  Future<void> loadInitData() async {
    emit(const ShopLoadedState());

    try {
      final result = await ShopRepo.listMyProducts();

      emit(
        ShopSuccessState(
          result.data ?? <Datum>[],
        ),
      );
    } on Exception catch (e) {
      emit(ShopErrorState(e.toString()));
    } on Object {
      emit(const ShopErrorState());
    }
  }

  Future<void> addProduct({
    required String name,
    required int price,
    String? description,
    String? category,
  }) async {
    emit(const ShopLoadingState());
    try {
      await ShopRepo.addProduct(
        name: name,
        price: price,
        description: description,
        category: category,
      );
      await loadInitData();
    } on Exception catch (e) {
      emit(ShopErrorState(e.toString()));
      await loadInitData();
    }
  }

  Future<void> updateProduct({
    required String id,
    String? name,
    int? price,
    String? description,
    String? category,
    String? status,
  }) async {
    try {
      await ShopRepo.updateProduct(
        id: id,
        name: name,
        price: price,
        description: description,
        category: category,
        status: status,
      );
      await loadInitData();
    } on Exception catch (e) {
      emit(ShopErrorState(e.toString()));
    }
  }

  Future<void> toggleProductStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      await ShopRepo.toggleProductStatus(
        id: id,
        isActive: isActive,
      );
      await loadInitData();
    } on Exception catch (e) {
      emit(ShopErrorState(e.toString()));
    }
  }

  Future<void> deleteProduct({
    required String id,
  }) async {
    try {
      await ShopRepo.deleteProduct(id: id);
      await loadInitData();
    } on Exception catch (e) {
      emit(ShopErrorState(e.toString()));
    }
  }
}
