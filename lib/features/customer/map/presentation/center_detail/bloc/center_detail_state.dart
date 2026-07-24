part of 'center_detail_bloc.dart';

/// Outcome of a one-shot review post, carried on [CenterDetailLoaded] so the
/// page's listener can toast it, then cleared (replaces the old bool return).
enum ReviewSubmission { success, failure }

abstract class CenterDetailState extends Equatable {
  const CenterDetailState();

  @override
  List<Object?> get props => [];
}

class CenterDetailInitial extends CenterDetailState {
  const CenterDetailInitial();
}

class CenterDetailLoading extends CenterDetailState {
  const CenterDetailLoading();
}

class CenterDetailLoaded extends CenterDetailState {
  const CenterDetailLoaded({
    required this.detail,
    required this.services,
    required this.reviews,
    this.review,
  });

  final CenterDetail detail;
  final List<CenterService> services;
  final List<Review> reviews;

  /// One-shot review-post outcome; null except for the single emit the page
  /// listens to. See [ReviewSubmission].
  final ReviewSubmission? review;

  CenterDetailLoaded withReview(ReviewSubmission? review) => CenterDetailLoaded(
    detail: detail,
    services: services,
    reviews: reviews,
    review: review,
  );

  @override
  List<Object?> get props => [detail, services, reviews, review];
}

class CenterDetailError extends CenterDetailState {
  const CenterDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
