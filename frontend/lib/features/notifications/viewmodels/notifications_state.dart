import 'package:equatable/equatable.dart';
import 'package:cinemora/features/notifications/models/notification.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<AppNotification> notifications;

  /// Server-reported on fetch, adjusted locally by optimistic mark-reads.
  /// Lives here (not derived from [notifications]) so the home-screen badge
  /// can be refreshed cheaply without loading the inbox.
  final int unreadCount;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  Map<String, List<AppNotification>> get grouped {
    final now = DateTime.now();
    final today = <AppNotification>[];
    final thisWeek = <AppNotification>[];
    final earlier = <AppNotification>[];

    for (final n in notifications) {
      final t = n.createdAt.toLocal();
      final sameDay =
          t.year == now.year && t.month == now.month && t.day == now.day;
      if (sameDay) {
        today.add(n);
      } else if (now.difference(t).inDays < 7) {
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

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, notifications, unreadCount, errorMessage];
}
