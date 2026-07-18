part of 'services_bloc.dart';

abstract class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesLoaded extends ServicesState {
  const ServicesLoaded(
    this.services, {
    this.acting = false,
    this.justDeleted = false,
  });

  final List<Service> services;

  /// A toggle/delete is in flight — the page shows a blocking overlay.
  final bool acting;

  /// One-shot: set after a delete completes so the page's listener fires the
  /// "service deleted" toast; the next emit clears it.
  final bool justDeleted;

  @override
  List<Object?> get props => [services, acting, justDeleted];
}

class ServicesError extends ServicesState {
  const ServicesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
