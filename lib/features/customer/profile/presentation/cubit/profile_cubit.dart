import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/customer/profile/data/repo/profile_repo.dart';
import 'package:osta/features/customer/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  Future<void> getProfile() async {
    emit(const ProfileLoading());
    try {
      final response = await ProfileRepo.getProfile();
      if (response != null &&
          response.success == true &&
          response.data != null) {
        emit(ProfileSuccess(response));
      } else {
        emit(const ProfileError('Failed to load profile data'));
      }
    } on Object catch (e, s) {
      log('Error in ProfileCubit.getProfile', error: e, stackTrace: s);
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> fetchProfile() => getProfile();
}
