import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/onboarding/data/repo/business_catalog_repo.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit() : super(InitialCataloggState());

  Future<void> loadInitData() async {
    emit(CatalogLoadedState());

    try {
      final result = await BusinessCatalogRepo.listServices();

      emit(
        CatalogSuccessState(result),
      );
    } on ValidationException catch (e) {
      print(e.fieldErrors);
      emit(CatalogErrorState());
    } on ApiException catch (e) {
      print(e.message);
      emit(CatalogErrorState());
    } catch (e) {
      print(e.toString());
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
    } on ValidationException catch (e) {
      print(e.fieldErrors);
      emit(CatalogErrorState());
    } on ApiException catch (e) {
      print(e.message);
      emit(CatalogErrorState());
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
    } on ValidationException catch (e) {
      print(e.fieldErrors);
      emit(CatalogErrorState());
    } on ApiException catch (e) {
      print(e.message);
      emit(CatalogErrorState());
    } catch (e) {
      emit(CatalogErrorState());
    }
  }
}
