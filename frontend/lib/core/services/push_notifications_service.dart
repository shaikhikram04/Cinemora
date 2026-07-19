import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cinemora/core/repositories/user_repository.dart';

/// Owns the FCM lifecycle: permission prompt, keeping the backend's copy of
/// the device token fresh, and message callbacks. Display is left to the OS —
/// a foreground message only nudges the unread badge (the user is already in
/// the app), and tapping a push lands on the notifications inbox.
class PushNotificationsService {
  final UserRepository _userRepository;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  bool _started = false;

  PushNotificationsService(this._userRepository);

  /// Call after sign-in. Safe to call again on later auth events — it only
  /// runs once per app session. Best-effort by design: any failure here
  /// (permission denied, no Play Services, offline) must never break sign-in.
  Future<void> start({
    required VoidCallback onForegroundMessage,
    required VoidCallback onNotificationTap,
  }) async {
    if (_started) return;
    _started = true;

    try {
      final messaging = FirebaseMessaging.instance;

      // Also covers Android 13+'s POST_NOTIFICATIONS runtime permission.
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token != null) await _userRepository.updateFcmToken(token);
      _tokenSub = messaging.onTokenRefresh.listen(
        (t) => _userRepository.updateFcmToken(t).catchError((_) {}),
      );

      _foregroundSub =
          FirebaseMessaging.onMessage.listen((_) => onForegroundMessage());

      // Tapped a push while the app was backgrounded…
      _openedSub = FirebaseMessaging.onMessageOpenedApp
          .listen((_) => onNotificationTap());
      // …or the tap is what launched the app from a terminated state.
      final initial = await messaging.getInitialMessage();
      if (initial != null) onNotificationTap();
    } catch (e) {
      _started = false; // let a later auth event retry
      debugPrint('Push setup skipped: $e');
    }
  }

  void dispose() {
    _tokenSub?.cancel();
    _foregroundSub?.cancel();
    _openedSub?.cancel();
  }
}
