part of 'address_bloc.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Load the caller's saved addresses (`/me/addresses`). Fired on first paint,
/// on pull-to-refresh, on retry, and after a create/edit/delete.
class AddressLoadRequested extends AddressEvent {
  const AddressLoadRequested();
}

/// Delete one saved address by id; the page reloads on success.
class AddressDeleteRequested extends AddressEvent {
  const AddressDeleteRequested(this.id);

  final Object id;

  @override
  List<Object?> get props => [id];
}
