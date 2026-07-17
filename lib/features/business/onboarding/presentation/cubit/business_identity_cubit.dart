import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/business/onboarding/data/repo/business_identity_repo.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_identity_state.dart';

class BusinessIdentityCubit extends Cubit<BusinessIdentityState> {
  BusinessIdentityCubit() : super(BusinessIdentityInitialState());

  Future<void> submitIdentity({
    required String tradeName,
    required String legalName,
    required String phone,
    required String type,
    required String city,
    String? logoPath,
    double? latitude,
    double? longitude,
  }) async {
    emit(BusinessIdentityLoadingState());

    try {
      await BusinessIdentityRepo.updateBusinessProfile(
        tradeName: tradeName,
        legalName: legalName,
        phone: phone,
        type: type,
        city: city,
        logoPath: logoPath,
        latitude: latitude,
        longitude: longitude,
      );

      emit(BusinessIdentitySuccessState());
    } catch (e) {
      emit(BusinessIdentityErrorState(message: e.toString()));
    }
  }
}
