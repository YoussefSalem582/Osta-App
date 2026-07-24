import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/profile/data/models/address.dart';
import 'package:osta/features/shared/profile/domain/address_repository.dart';

part 'address_event.dart';
part 'address_state.dart';

/// The caller's saved addresses (`/me/addresses`) — list + delete. Create and
/// edit are self-contained in `AddressFormPage`; this bloc reloads after
/// them.
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc(this._repo) : super(const AddressInitial()) {
    on<AddressLoadRequested>(_onLoadRequested);
    on<AddressDeleteRequested>(_onDeleteRequested);
  }

  final AddressRepository _repo;

  Future<void> _onLoadRequested(
    AddressLoadRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final items = await _repo.list();
      emit(AddressLoaded(items));
    } on ApiException catch (e) {
      emit(AddressError(e.message));
    } on Object catch (e, s) {
      log('AddressBloc.load failed', error: e, stackTrace: s);
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    AddressDeleteRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressDeleteLoading());
    try {
      await _repo.delete(event.id);
      emit(const AddressDeleteSuccess());
    } on ApiException catch (e) {
      emit(AddressDeleteError(e.message));
    } on Object catch (e, s) {
      log('AddressBloc.delete failed', error: e, stackTrace: s);
      emit(AddressDeleteError(e.toString()));
    }
  }
}
