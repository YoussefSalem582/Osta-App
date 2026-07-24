part of 'address_bloc.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  const AddressLoaded(this.items);

  final List<Address> items;

  @override
  List<Object?> get props => [items];
}

class AddressError extends AddressState {
  const AddressError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Delete sub-states (list stays rendered from the page's local copy) ──

class AddressDeleteLoading extends AddressState {
  const AddressDeleteLoading();
}

class AddressDeleteSuccess extends AddressState {
  const AddressDeleteSuccess();
}

class AddressDeleteError extends AddressState {
  const AddressDeleteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
