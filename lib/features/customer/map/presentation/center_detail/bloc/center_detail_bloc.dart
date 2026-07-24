import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/customer/map/data/models/center_detail.dart';
import 'package:osta/features/customer/map/domain/center_detail_repository.dart';
import 'package:osta/features/shared/reviews/data/model/review.dart';
import 'package:osta/features/shared/reviews/data/repo/review_repo.dart';

part 'center_detail_event.dart';
part 'center_detail_state.dart';

/// Loads a center's profile, services and reviews together; a posted review
/// comes back pending, so it won't reappear in the approved index yet.
class CenterDetailBloc extends Bloc<CenterDetailEvent, CenterDetailState> {
  CenterDetailBloc(this._repo, this.centerId)
    : super(const CenterDetailInitial()) {
    on<CenterDetailStarted>(_onStarted);
    on<CenterDetailReviewSubmitted>(_onReviewSubmitted);
    on<CenterDetailReviewNoticeCleared>(_onReviewNoticeCleared);
  }

  final CenterDetailRepository _repo;

  final Object centerId;

  Future<void> _onStarted(
    CenterDetailStarted event,
    Emitter<CenterDetailState> emit,
  ) async {
    emit(const CenterDetailLoading());
    try {
      final detail = await _repo.detail(centerId);
      // Services / reviews are secondary — a failure there shouldn't blank the
      // whole page, so they degrade to empty.
      final services = await _servicesOrEmpty(detail);
      final reviews = await _reviewsOrEmpty();
      emit(
        CenterDetailLoaded(
          detail: detail,
          services: services,
          reviews: reviews,
        ),
      );
    } on ApiException catch (e) {
      emit(CenterDetailError(e.message));
    } on Object catch (e, s) {
      log('CenterDetailBloc.load failed', error: e, stackTrace: s);
      emit(CenterDetailError(e.toString()));
    }
  }

  /// Posts a review; the outcome lands on [CenterDetailLoaded.review] so the
  /// page's listener can toast, then clears it via
  /// [CenterDetailReviewNoticeCleared] (replaces the old `Future<bool>`).
  Future<void> _onReviewSubmitted(
    CenterDetailReviewSubmitted event,
    Emitter<CenterDetailState> emit,
  ) async {
    final current = state;
    if (current is! CenterDetailLoaded) return;
    try {
      await ReviewRepo.postCenterReview(
        centerId,
        rating: event.rating,
        comment: event.comment,
      );
      emit(current.withReview(ReviewSubmission.success));
    } on Object catch (e, s) {
      log('CenterDetailBloc.postReview failed', error: e, stackTrace: s);
      emit(current.withReview(ReviewSubmission.failure));
    }
  }

  void _onReviewNoticeCleared(
    CenterDetailReviewNoticeCleared event,
    Emitter<CenterDetailState> emit,
  ) {
    final current = state;
    if (current is CenterDetailLoaded) emit(current.withReview(null));
  }

  Future<List<CenterService>> _servicesOrEmpty(CenterDetail detail) async {
    if (detail.services.isNotEmpty) return detail.services;
    try {
      return await _repo.services(centerId);
    } on Object {
      return const [];
    }
  }

  Future<List<Review>> _reviewsOrEmpty() async {
    try {
      final result = await ReviewRepo.centerReviews(centerId);
      return result.data;
    } on Object {
      return const [];
    }
  }
}
