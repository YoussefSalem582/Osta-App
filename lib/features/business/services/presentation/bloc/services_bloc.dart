import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/business/services/data/repo/business_service_repo.dart';

part 'services_event.dart';
part 'services_state.dart';

/// The owner's service catalogue (`GET /business/services`) — list + toggle
/// active (`PUT`) + soft-delete (`DELETE`). Create/edit are self-contained in
/// `ServiceFormScreen`; this bloc reloads after them.
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc() : super(const ServicesInitial()) {
    on<ServicesLoadRequested>(_onLoadRequested);
    on<ServicesActiveToggled>(_onActiveToggled);
    on<ServicesDeleteRequested>(_onDeleteRequested);
  }

  List<Service> _items = const [];

  Future<void> _onLoadRequested(
    ServicesLoadRequested event,
    Emitter<ServicesState> emit,
  ) => _load(emit);

  Future<void> _onActiveToggled(
    ServicesActiveToggled event,
    Emitter<ServicesState> emit,
  ) => _act(
    emit,
    () => BusinessServiceRepo.updateService(
      event.service.id,
      isActive: event.isActive,
    ),
  );

  Future<void> _onDeleteRequested(
    ServicesDeleteRequested event,
    Emitter<ServicesState> emit,
  ) async {
    await _act(emit, () => BusinessServiceRepo.deleteService(event.service.id));
    // The page awaited `delete()` before toasting; a Bloc handler can't hand
    // completion back, so flag it on state and let the page's listener toast.
    final current = state;
    if (current is ServicesLoaded) {
      emit(ServicesLoaded(current.services, justDeleted: true));
    }
  }

  Future<void> _load(Emitter<ServicesState> emit) async {
    emit(const ServicesLoading());
    try {
      _items = await BusinessServiceRepo.index();
      emit(ServicesLoaded(_items));
    } on ApiException catch (e) {
      emit(ServicesError(e.message));
    } on Object catch (e, s) {
      log('ServicesBloc load failed', error: e, stackTrace: s);
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> _act(
    Emitter<ServicesState> emit,
    Future<void> Function() action,
  ) async {
    emit(ServicesLoaded(_items, acting: true));
    try {
      await action();
      await _load(emit);
    } on ApiException catch (e) {
      emit(ServicesError(e.message));
      emit(ServicesLoaded(_items));
    } on Object catch (e, s) {
      log('ServicesBloc action failed', error: e, stackTrace: s);
      emit(ServicesLoaded(_items));
    }
  }
}
