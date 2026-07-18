import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/profile/data/model/address.dart';
import 'package:osta/features/shared/profile/data/repo/address_repo.dart';

part 'address_event.dart';
part 'address_state.dart';

/// The caller's saved addresses (`/me/addresses`) — list + delete. Create and
/// edit are self-contained in `AddressFormScreen`; this bloc reloads after
/// them.
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(const AddressInitial()) {
    on<AddressLoadRequested>(_onLoadRequested);
    on<AddressDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    AddressLoadRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    try {
      final items = await AddressRepo.list();
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
      await AddressRepo.delete(event.id);
      emit(const AddressDeleteSuccess());
    } on ApiException catch (e) {
      emit(AddressDeleteError(e.message));
    } on Object catch (e, s) {
      log('AddressBloc.delete failed', error: e, stackTrace: s);
      emit(AddressDeleteError(e.toString()));
    }
  }
}
