class BusinessIdentityState {}

class BusinessIdentityInitialState extends BusinessIdentityState {}

class BusinessIdentityLoadingState extends BusinessIdentityState {}

class BusinessIdentitySuccessState extends BusinessIdentityState {}

class BusinessIdentityErrorState extends BusinessIdentityState {
  BusinessIdentityErrorState({this.message});
  final String? message;
}
