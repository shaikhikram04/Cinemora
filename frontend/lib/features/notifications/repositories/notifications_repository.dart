import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/notifications/models/notification.dart';

class NotificationsPage {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsPage({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<NotificationsPage> fetch({int page = 1, int limit = 50}) async {
    try {
      final res = await _apiClient.dio.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = res.data as Map<String, dynamic>;
      return NotificationsPage(
        notifications: (data['notifications'] as List)
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList(),
        unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  /// Cheap poll for the home-screen bell badge — also triggers the backend's
  /// compute-on-read generation pass, so the badge can light up without the
  /// user ever opening the inbox.
  Future<int> fetchUnreadCount() async {
    try {
      final res = await _apiClient.dio.get('/notifications/unread-count');
      return ((res.data as Map<String, dynamic>)['unreadCount'] as num?)
              ?.toInt() ??
          0;
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _apiClient.dio.put('/notifications/$id/read');
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.dio.put('/notifications/read-all');
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }
}
