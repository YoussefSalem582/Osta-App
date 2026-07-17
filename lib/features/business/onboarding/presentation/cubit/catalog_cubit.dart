import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/business/onboarding/data/repo/business_catalog_repo.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit() : super(InitialCataloggState());

  Future<void> loadInitData() async {
    emit(CatalogLoadedState());

    try {
      final result = await BusinessCatalogRepo.listServices();

      emit(
        CatalogSuccessState(
          result.data ?? [],
        ),
      );
    } catch (e) {
      print(e);

      emit(CatalogErrorState());
    }
  }

  // ------------------------------------------------------
  Future<void> addservice({
    required String name,
    required int price,
    required int duration,
  }) async {
    try {
      await BusinessCatalogRepo.addService(
        name: name,
        price: price,
        durationMinutes: duration,
      );
      await loadInitData();
    } catch (e) {
      emit(CatalogErrorState());
    }
  }

  // ------------------------------------------------------
  Future<void> addCustomService({
    required String name,
    required int price,
    required int duration,
  }) async {
    try {
      await BusinessCatalogRepo.addService(
        name: name,
        price: price,
        durationMinutes: duration,
      );

      await loadInitData();
    } catch (e) {
      emit(CatalogErrorState());
    }
  }
}
