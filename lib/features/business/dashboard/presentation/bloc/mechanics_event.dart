part of 'mechanics_bloc.dart';

sealed class MechanicsEvent extends Equatable {
  const MechanicsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the owner's mechanic roster. Fired on first paint and by
/// the error-state retry button.
class MechanicsLoadRequested extends MechanicsEvent {
  const MechanicsLoadRequested();
}

/// Flip a mechanic's `is_active` from the row switch.
class MechanicsActiveToggled extends MechanicsEvent {
  const MechanicsActiveToggled(this.mechanic, {required this.isActive});

  final Mechanic mechanic;
  final bool isActive;

  @override
  List<Object?> get props => [mechanic, isActive];
}

/// Delete a mechanic; the page toasts once it completes.
class MechanicsDeleteRequested extends MechanicsEvent {
  const MechanicsDeleteRequested(this.mechanic);

  final Mechanic mechanic;

  @override
  List<Object?> get props => [mechanic];
}
