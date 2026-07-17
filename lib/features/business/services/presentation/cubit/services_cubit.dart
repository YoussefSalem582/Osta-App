import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/business/services/data/repo/business_services_repo.dart';
import 'package:osta/features/business/services/presentation/cubit/services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit() : super(InitialServicesState());

  Future<void> loadServices() async {
    emit(ServicesLoadingState());

    try {
      final servicesResult = await BusinessServicesRepo.listServices();
      final promotionsResult = await BusinessServicesRepo.listPromotions();

      emit(
        ServicesSuccessState(
          services: servicesResult.data ?? [],
          promotions: promotionsResult.data ?? [],
        ),
      );
    } catch (e) {
      print(e);
      emit(ServicesErrorState());
    }
  }

  // ------------------------------------------------------
  Future<void> addService({
    required String name,
    required int price,
    required int duration,
  }) async {
    try {
      await BusinessServicesRepo.addService(
        name: name,
        price: price,
        durationMinutes: duration,
      );
      await loadServices();
    } catch (e) {
      emit(ServicesErrorState());
    }
  }

  // ------------------------------------------------------
  Future<void> toggleService({
    required String serviceId,
    required bool isActive,
  }) async {
    try {
      await BusinessServicesRepo.toggleService(
        serviceId: serviceId,
        isActive: isActive,
      );
      await loadServices();
    } catch (e) {
      emit(ServicesErrorState());
    }
  }

  // ------------------------------------------------------
  Future<void> addPromotion({
    required String title,
    required String subtitle,
    required int discountPercentage,
  }) async {
    try {
      await BusinessServicesRepo.addPromotion(
        title: title,
        subtitle: subtitle,
        discountPercentage: discountPercentage,
      );
      await loadServices();
    } catch (e) {
      emit(ServicesErrorState());
    }
  }
}
