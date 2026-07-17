import 'package:equatable/equatable.dart';
import 'package:osta/features/customer/profile/data/model/profile_response/profile_response.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}


class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.profile);

  final ProfileResponse profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  const ProfileError(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class ProfileUpdateLoading extends ProfileState {
  const ProfileUpdateLoading();
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess(this.profile);

  final ProfileResponse profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateError extends ProfileState {
  const ProfileUpdateError(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}


class ProfileAvatarUploading extends ProfileState {
  const ProfileAvatarUploading();
}

class ProfileAvatarSuccess extends ProfileState {
  const ProfileAvatarSuccess(this.profile);

  final ProfileResponse profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileAvatarError extends ProfileState {
  const ProfileAvatarError(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class ProfileDeleteLoading extends ProfileState {
  const ProfileDeleteLoading();
}

class ProfileDeleteSuccess extends ProfileState {
  const ProfileDeleteSuccess();
}

class ProfileDeleteError extends ProfileState {
  const ProfileDeleteError(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
