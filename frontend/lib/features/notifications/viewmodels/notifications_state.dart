import 'package:equatable/equatable.dart';
import 'package:cinemora/features/notifications/models/notification.dart';

class NotificationsState extends Equatable {
  final List<WNotif> notifications;

  const NotificationsState({this.notifications = kInitialNotifications});

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Map<String, List<WNotif>> get grouped {
    final today = <WNotif>[];
    final thisWeek = <WNotif>[];
    final earlier = <WNotif>[];

    for (final n in notifications) {
      final t = n.timeLabel;
      if (t.contains('m ago') || t.contains('h ago')) {
        today.add(n);
      } else if (t.contains('d ago')) {
        thisWeek.add(n);
      } else {
        earlier.add(n);
      }
    }

    return {
      if (today.isNotEmpty) 'Today': today,
      if (thisWeek.isNotEmpty) 'This Week': thisWeek,
      if (earlier.isNotEmpty) 'Earlier': earlier,
    };
  }

  NotificationsState copyWith({List<WNotif>? notifications}) =>
      NotificationsState(notifications: notifications ?? this.notifications);

  @override
  List<Object> get props => [notifications];
}
