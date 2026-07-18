import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/notifications/data/model/app_notification.dart';
import 'package:osta/features/shared/notifications/data/repo/notification_repo.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// The authenticated user's notification feed (`/notifications`) — list + mark
/// read. Static repo like the other features; the local `_items` copy lets a
/// single row flip to read without a full reload.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationsMarkReadRequested>(_onMarkReadRequested);
    on<NotificationsMarkAllReadRequested>(_onMarkAllReadRequested);
  }

  final List<AppNotification> _items = [];

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      final result = await NotificationRepo.list(perPage: 50);
      _items
        ..clear()
        ..addAll(result.data);
      emit(NotificationsLoaded(List.of(_items)));
    } on ApiException catch (e) {
      emit(NotificationsError(e.message));
    } on Object catch (e, s) {
      log('NotificationsBloc.load failed', error: e, stackTrace: s);
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkReadRequested(
    NotificationsMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) => _markRead(event.id, emit);

  /// Marks every currently-unread row read (each hits `POST .../read`).
  Future<void> _onMarkAllReadRequested(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final unread = _items.where((n) => !n.isRead).map((n) => n.id).toList();
    for (final id in unread) {
      await _markRead(id, emit);
    }
  }

  /// Marks one notification read and swaps it in place. On failure the row
  /// simply stays unread (logged, no error surface — a background flip).
  Future<void> _markRead(String id, Emitter<NotificationsState> emit) async {
    try {
      final updated = await NotificationRepo.markRead(id);
      final index = _items.indexWhere((n) => n.id == id);
      if (index != -1) _items[index] = updated;
      emit(NotificationsLoaded(List.of(_items)));
    } on Object catch (e, s) {
      log('NotificationsBloc.markRead failed', error: e, stackTrace: s);
    }
  }
}
