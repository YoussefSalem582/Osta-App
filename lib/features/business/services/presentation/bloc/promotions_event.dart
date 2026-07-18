part of 'promotions_bloc.dart';

sealed class PromotionsEvent extends Equatable {
  const PromotionsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the owner's promotion list. Fired on first paint and by
/// the error-state retry button.
class PromotionsLoadRequested extends PromotionsEvent {
  const PromotionsLoadRequested();
}

/// Flip a promotion's `is_active` from the row switch.
class PromotionsActiveToggled extends PromotionsEvent {
  const PromotionsActiveToggled(this.promotion, {required this.isActive});

  final Promotion promotion;
  final bool isActive;

  @override
  List<Object?> get props => [promotion, isActive];
}

/// Delete a promotion; the page toasts once it completes.
class PromotionsDeleteRequested extends PromotionsEvent {
  const PromotionsDeleteRequested(this.promotion);

  final Promotion promotion;

  @override
  List<Object?> get props => [promotion];
}
