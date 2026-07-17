import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/shop/data/Model/products/datum.dart';
import 'package:osta/features/shop/data/repo/shop_repo.dart';
import 'package:osta/features/shop/presentation/cubit/shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(InitialShopState());

  Future<void> loadInitData() async {
    emit(ShopLoadedState());

    try {
      final result = await ShopRepo.listProducts();

      emit(
        ShopSuccessState(
          result.data ?? <Datum>[],
        ),
      );
    } on Exception {
      emit(ShopErrorState());
    } on Object {
      emit(ShopErrorState());
    }
  }
}
