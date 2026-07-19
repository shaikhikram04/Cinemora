import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/notifications/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repo;

  NotificationsCubit(this._repo) : super(const NotificationsState());

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final page = await _repo.fetch();
      emit(NotificationsState(
        status: NotificationsStatus.success,
        notifications: page.notifications,
        unreadCount: page.unreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: ApiClient.parseError(e).userMessage,
      ));
    }
  }

  /// Badge-only refresh, called on sign-in/app start. Best effort: a failed
  /// poll just leaves the badge as-is — never surfaces an error.
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repo.fetchUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {}
  }

  void markRead(String id) {
    final idx = state.notifications.indexWhere((n) => n.id == id);
    if (idx < 0 || state.notifications[idx].isRead) return;

    // Optimistic: flip locally, sync in the background. A failed sync just
    // means the item shows unread again on the next load.
    emit(state.copyWith(
      notifications: [
        for (final n in state.notifications)
          n.id == id ? n.copyWith(isRead: true) : n,
      ],
      unreadCount: (state.unreadCount - 1).clamp(0, 1 << 31),
    ));
    _repo.markRead(id).catchError((_) {});
  }

  void markAllRead() {
    if (state.unreadCount == 0 && state.notifications.every((n) => n.isRead)) {
      return;
    }
    emit(state.copyWith(
      notifications: [
        for (final n in state.notifications) n.copyWith(isRead: true),
      ],
      unreadCount: 0,
    ));
    _repo.markAllRead().catchError((_) {});
  }

  /// Reset on sign-out so the next account doesn't see stale rows.
  void clear() => emit(const NotificationsState());
}
