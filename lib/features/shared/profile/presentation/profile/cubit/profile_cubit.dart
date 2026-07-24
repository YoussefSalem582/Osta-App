import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/profile/data/models/profile_response/profile_response.dart';
import 'package:osta/features/shared/profile/domain/profile_repository.dart';
import 'package:osta/features/shared/profile/presentation/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileInitial());

  final ProfileRepository _repo;

  Future<void> getProfile() async {
    final cached = _repo.cachedProfile;
    if (cached != null) {
      emit(
        ProfileSuccess(
          ProfileResponse(success: true, data: cached),
          fromCache: true,
          fetchedAt: _repo.cachedAt,
        ),
      );
    } else {
      emit(const ProfileLoading());
    }

    try {
      final response = await _repo.getProfile();
      if (response.success == true && response.data != null) {
        emit(ProfileSuccess(response));
      } else if (cached == null) {
        emit(const ProfileError('Failed to load profile data'));
      }
    } on NetworkException catch (e, s) {
      log('Offline in ProfileCubit.getProfile', error: e, stackTrace: s);
      if (cached == null) emit(ProfileError(e.message));
    } on Object catch (e, s) {
      log('Error in ProfileCubit.getProfile', error: e, stackTrace: s);
      if (cached == null) emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
  }) async {
    emit(const ProfileUpdateLoading());
    try {
      final response = await _repo.updateProfile(
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
      final response = await _repo.uploadAvatar(filePath);
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
      await _repo.deleteAccount();
      emit(const ProfileDeleteSuccess());
    } on Object catch (e, s) {
      log('Error in ProfileCubit.deleteAccount', error: e, stackTrace: s);
      emit(ProfileDeleteError(e.toString()));
    }
  }
}
