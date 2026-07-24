part of 'center_detail_bloc.dart';

sealed class CenterDetailEvent extends Equatable {
  const CenterDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load the center, its services and its reviews together. Fired on first
/// paint and by the error state's retry button.
class CenterDetailStarted extends CenterDetailEvent {
  const CenterDetailStarted();
}

/// Post a review; the outcome surfaces on [CenterDetailLoaded.review].
class CenterDetailReviewSubmitted extends CenterDetailEvent {
  const CenterDetailReviewSubmitted({required this.rating, this.comment});

  final int rating;
  final String? comment;

  @override
  List<Object?> get props => [rating, comment];
}

/// Clears the one-shot review outcome once the page has toasted it, so a
/// repeat submission with the same outcome still fires the listener.
class CenterDetailReviewNoticeCleared extends CenterDetailEvent {
  const CenterDetailReviewNoticeCleared();
}
