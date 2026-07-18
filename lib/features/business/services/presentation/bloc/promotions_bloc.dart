import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/services/data/model/promotion.dart';
import 'package:osta/features/business/services/data/repo/promotion_repo.dart';

part 'promotions_event.dart';
part 'promotions_state.dart';

/// The owner's promotion list (`GET /business/promotions`) — list + toggle
/// active (`PUT`) + delete (`DELETE`). Create/edit are self-contained in
/// `PromotionFormScreen`; this bloc reloads after them. Mirrors `ServicesBloc`.
class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  PromotionsBloc() : super(const PromotionsInitial()) {
    on<PromotionsLoadRequested>(_onLoadRequested);
    on<PromotionsActiveToggled>(_onActiveToggled);
    on<PromotionsDeleteRequested>(_onDeleteRequested);
  }

  List<Promotion> _items = const [];

  Future<void> _onLoadRequested(
    PromotionsLoadRequested event,
    Emitter<PromotionsState> emit,
  ) => _load(emit);

  Future<void> _onActiveToggled(
    PromotionsActiveToggled event,
    Emitter<PromotionsState> emit,
  ) => _act(
    emit,
    () => PromotionRepo.update(event.promotion.id, isActive: event.isActive),
  );

  Future<void> _onDeleteRequested(
    PromotionsDeleteRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    await _act(emit, () => PromotionRepo.destroy(event.promotion.id));
    // The page awaited `delete()` before toasting; a Bloc handler can't hand
    // completion back, so flag it on state and let the page's listener toast.
    final current = state;
    if (current is PromotionsLoaded) {
      emit(PromotionsLoaded(current.promotions, justDeleted: true));
    }
  }

  Future<void> _load(Emitter<PromotionsState> emit) async {
    emit(const PromotionsLoading());
    try {
      _items = await PromotionRepo.index();
      emit(PromotionsLoaded(_items));
    } on ApiException catch (e) {
      emit(PromotionsError(e.message));
    } on Object catch (e, s) {
      log('PromotionsBloc load failed', error: e, stackTrace: s);
      emit(PromotionsError(e.toString()));
    }
  }

  Future<void> _act(
    Emitter<PromotionsState> emit,
    Future<void> Function() action,
  ) async {
    emit(PromotionsLoaded(_items, acting: true));
    try {
      await action();
      await _load(emit);
    } on ApiException catch (e) {
      emit(PromotionsError(e.message));
      emit(PromotionsLoaded(_items));
    } on Object catch (e, s) {
      log('PromotionsBloc action failed', error: e, stackTrace: s);
      emit(PromotionsLoaded(_items));
    }
  }
}
