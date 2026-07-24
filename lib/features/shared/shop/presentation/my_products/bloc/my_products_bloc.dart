import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/shop/data/models/product.dart';
import 'package:osta/features/shared/shop/domain/shop_repository.dart';

part 'my_products_event.dart';
part 'my_products_state.dart';

/// The caller's own shop listings (`/me/products`) — list + delete. Create and
/// edit are self-contained in `ProductFormPage`; this bloc reloads after them.
class MyProductsBloc extends Bloc<MyProductsEvent, MyProductsState> {
  MyProductsBloc(this._repo) : super(const MyProductsInitial()) {
    on<MyProductsLoadRequested>(_onLoadRequested);
    on<MyProductsDeleteRequested>(_onDeleteRequested);
  }

  final ShopRepository _repo;

  Future<void> _onLoadRequested(
    MyProductsLoadRequested event,
    Emitter<MyProductsState> emit,
  ) async {
    emit(const MyProductsLoading());
    try {
      final result = await _repo.myProducts();
      emit(MyProductsLoaded(result.data));
    } on ApiException catch (e) {
      emit(MyProductsError(e.message));
    } on Object catch (e, s) {
      log('MyProductsBloc.load failed', error: e, stackTrace: s);
      emit(MyProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    MyProductsDeleteRequested event,
    Emitter<MyProductsState> emit,
  ) async {
    emit(const MyProductsDeleteLoading());
    try {
      await _repo.deleteProduct(event.id);
      emit(const MyProductsDeleteSuccess());
    } on ApiException catch (e) {
      emit(MyProductsDeleteError(e.message));
    } on Object catch (e, s) {
      log('MyProductsBloc.delete failed', error: e, stackTrace: s);
      emit(MyProductsDeleteError(e.toString()));
    }
  }
}
