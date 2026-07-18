import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/team/data/model/mechanic.dart';
import 'package:osta/features/business/team/data/repo/mechanic_repo.dart';

part 'mechanics_event.dart';
part 'mechanics_state.dart';

/// The owner's mechanic roster (`GET /business/mechanics`) — list + toggle
/// active (`PATCH`) + delete. Create/edit are self-contained in
/// `MechanicFormScreen`; this bloc reloads after them.
class MechanicsBloc extends Bloc<MechanicsEvent, MechanicsState> {
  MechanicsBloc() : super(const MechanicsInitial()) {
    on<MechanicsLoadRequested>(_onLoadRequested);
    on<MechanicsActiveToggled>(_onActiveToggled);
    on<MechanicsDeleteRequested>(_onDeleteRequested);
  }

  List<Mechanic> _items = const [];

  Future<void> _onLoadRequested(
    MechanicsLoadRequested event,
    Emitter<MechanicsState> emit,
  ) => _load(emit);

  Future<void> _onActiveToggled(
    MechanicsActiveToggled event,
    Emitter<MechanicsState> emit,
  ) => _act(
    emit,
    () => MechanicRepo.update(event.mechanic.id, isActive: event.isActive),
  );

  Future<void> _onDeleteRequested(
    MechanicsDeleteRequested event,
    Emitter<MechanicsState> emit,
  ) async {
    await _act(emit, () => MechanicRepo.destroy(event.mechanic.id));
    // The page awaited `delete()` before toasting; a Bloc handler can't hand
    // completion back, so flag it on state and let the page's listener toast.
    final current = state;
    if (current is MechanicsLoaded) {
      emit(MechanicsLoaded(current.mechanics, justDeleted: true));
    }
  }

  Future<void> _load(Emitter<MechanicsState> emit) async {
    emit(const MechanicsLoading());
    try {
      _items = await MechanicRepo.index();
      emit(MechanicsLoaded(_items));
    } on ApiException catch (e) {
      emit(MechanicsError(e.message));
    } on Object catch (e, s) {
      log('MechanicsBloc load failed', error: e, stackTrace: s);
      emit(MechanicsError(e.toString()));
    }
  }

  Future<void> _act(
    Emitter<MechanicsState> emit,
    Future<void> Function() action,
  ) async {
    emit(MechanicsLoaded(_items, acting: true));
    try {
      await action();
      await _load(emit);
    } on ApiException catch (e) {
      emit(MechanicsError(e.message));
      emit(MechanicsLoaded(_items));
    } on Object catch (e, s) {
      log('MechanicsBloc action failed', error: e, stackTrace: s);
      emit(MechanicsLoaded(_items));
    }
  }
}
