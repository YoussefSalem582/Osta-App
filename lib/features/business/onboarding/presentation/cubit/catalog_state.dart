import 'package:osta/features/business/onboarding/data/Model/servise_model/datum.dart';

class CatalogState {}

class InitialCataloggState extends CatalogState {}

class CatalogLoadedState extends CatalogState {}

class CatalogSuccessState extends CatalogState {
  CatalogSuccessState(this.services);
  final List<Datum> services;
}

class CatalogErrorState extends CatalogState {}
