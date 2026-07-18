part of 'promotions_bloc.dart';

abstract class PromotionsState extends Equatable {
  const PromotionsState();

  @override
  List<Object?> get props => [];
}

class PromotionsInitial extends PromotionsState {
  const PromotionsInitial();
}

class PromotionsLoading extends PromotionsState {
  const PromotionsLoading();
}

class PromotionsLoaded extends PromotionsState {
  const PromotionsLoaded(
    this.promotions, {
    this.acting = false,
    this.justDeleted = false,
  });

  final List<Promotion> promotions;

  /// A toggle/delete is in flight — the page shows a blocking overlay.
  final bool acting;

  /// One-shot: set after a delete completes so the page's listener fires the
  /// "promotion deleted" toast; the next emit clears it.
  final bool justDeleted;

  @override
  List<Object?> get props => [promotions, acting, justDeleted];
}

class PromotionsError extends PromotionsState {
  const PromotionsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
