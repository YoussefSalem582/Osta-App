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

  // Future<void> fetchProfile() => getProfile();

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
  }) async {
    emit(const ProfileUpdateLoading());
    try {
      final response = await ProfileRepo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phone: phone,
      );
      if (response != null &&
          response.success == true &&
          response.data != null) {
        emit(ProfileUpdateSuccess(response));
      } else {
        emit(const ProfileUpdateError('Failed to update profile'));
      }
    } on Object catch (e, s) {
      log('Error in ProfileCubit.updateProfile', error: e, stackTrace: s);
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    emit(const ProfileAvatarUploading());
    try {
      final response = await ProfileRepo.uploadAvatar(filePath);
      if (response != null &&
          response.success == true &&
          response.data != null) {
        emit(ProfileAvatarSuccess(response));
      } else {
        emit(const ProfileAvatarError('Failed to upload avatar'));
      }
    } on Object catch (e, s) {
      log('Error in ProfileCubit.uploadAvatar', error: e, stackTrace: s);
      emit(ProfileAvatarError(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(const ProfileDeleteLoading());
    try {
      await ProfileRepo.deleteAccount();
      emit(const ProfileDeleteSuccess());
    } on Object catch (e, s) {
      log('Error in ProfileCubit.deleteAccount', error: e, stackTrace: s);
      emit(ProfileDeleteError(e.toString()));
    }
  }
}
