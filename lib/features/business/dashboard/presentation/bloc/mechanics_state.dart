part of 'mechanics_bloc.dart';

abstract class MechanicsState extends Equatable {
  const MechanicsState();

  @override
  List<Object?> get props => [];
}

class MechanicsInitial extends MechanicsState {
  const MechanicsInitial();
}

class MechanicsLoading extends MechanicsState {
  const MechanicsLoading();
}

class MechanicsLoaded extends MechanicsState {
  const MechanicsLoaded(
    this.mechanics, {
    this.acting = false,
    this.justDeleted = false,
  });

  final List<Mechanic> mechanics;

  /// A toggle/delete is in flight — the page shows a blocking overlay.
  final bool acting;

  /// One-shot: set after a delete completes so the page's listener fires the
  /// "technician removed" toast; the next emit clears it.
  final bool justDeleted;

  @override
  List<Object?> get props => [mechanics, acting, justDeleted];
}

class MechanicsError extends MechanicsState {
  const MechanicsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
