part of 'services_bloc.dart';

sealed class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the owner's service catalogue. Fired on first paint and by
/// the error-state retry button.
class ServicesLoadRequested extends ServicesEvent {
  const ServicesLoadRequested();
}

/// Flip a service's `is_active` from the row switch.
class ServicesActiveToggled extends ServicesEvent {
  const ServicesActiveToggled(this.service, {required this.isActive});

  final Service service;
  final bool isActive;

  @override
  List<Object?> get props => [service, isActive];
}

/// Soft-delete a service; the page toasts once it completes.
class ServicesDeleteRequested extends ServicesEvent {
  const ServicesDeleteRequested(this.service);

  final Service service;

  @override
  List<Object?> get props => [service];
}
