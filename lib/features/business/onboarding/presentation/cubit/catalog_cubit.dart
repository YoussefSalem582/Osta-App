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
}
