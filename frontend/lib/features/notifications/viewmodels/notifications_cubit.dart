import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  void markAllRead() {
    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
    ));
  }

  void markRead(String id) {
    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    ));
  }
}
