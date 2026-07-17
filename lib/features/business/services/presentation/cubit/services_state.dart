import 'package:osta/features/business/services/data/models/promotion_model/promotion_item.dart';
import 'package:osta/features/business/services/data/models/services_model/service_item.dart';

class ServicesState {}

class InitialServicesState extends ServicesState {}

class ServicesLoadingState extends ServicesState {}

class ServicesSuccessState extends ServicesState {
  ServicesSuccessState({
    required this.services,
    required this.promotions,
  });

  final List<ServiceItem> services;
  final List<PromotionItem> promotions;
}

class ServicesErrorState extends ServicesState {}
