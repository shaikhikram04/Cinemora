import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cinemora/core/repositories/user_repository.dart';

/// Owns the FCM lifecycle: permission prompt, keeping the backend's copy of
/// the device token fresh, and message callbacks. Display is left to the OS —
/// a foreground message only nudges the unread badge (the user is already in
/// the app), and a tap hands the whole message to the caller, which routes on
/// the payload the backend attached.
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
    required void Function(RemoteMessage message) onNotificationTap,
  }) async {
    if (_started) return;
    _started = true;

    try {
      final messaging = FirebaseMessaging.instance;

      // Also covers Android 13+'s POST_NOTIFICATIONS runtime permission.
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        // Unlatch: without this, a user who grants permission later in OS
        // settings gets no push until the app is restarted, because every
        // later call to start() short-circuits.
        _started = false;
        return;
      }

      final token = await messaging.getToken();
      if (token != null) await _userRepository.updateFcmToken(token);
      _tokenSub = messaging.onTokenRefresh.listen(
        (t) => _userRepository.updateFcmToken(t).catchError((_) {}),
      );

      _foregroundSub =
          FirebaseMessaging.onMessage.listen((_) => onForegroundMessage());

      // Tapped a push while the app was backgrounded…
      _openedSub =
          FirebaseMessaging.onMessageOpenedApp.listen(onNotificationTap);
      // …or the tap is what launched the app from a terminated state.
      final initial = await messaging.getInitialMessage();
      if (initial != null) onNotificationTap(initial);
    } catch (e) {
      _started = false; // let a later auth event retry
      debugPrint('Push setup skipped: $e');
    }
  }

  /// The OS-level permission as it stands right now. Settings reads this so it
  /// can stop presenting toggles as live when the OS is dropping everything.
  Future<AuthorizationStatus> permissionStatus() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (_) {
      // No Play Services, no Firebase — treat as "can't tell, don't nag".
      return AuthorizationStatus.notDetermined;
    }
  }

  /// Prompts for permission and, if it's granted, registers the token that
  /// [start] couldn't get earlier. Returns the status the user landed on.
  ///
  /// Only useful while the OS still shows a prompt; once permission has been
  /// hard-denied this returns denied without any UI, and the only way back is
  /// the system settings screen.
  Future<AuthorizationStatus> requestPermissionAndRegister() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      final status = settings.authorizationStatus;
      if (status == AuthorizationStatus.denied) return status;

      final token = await messaging.getToken();
      if (token != null) await _userRepository.updateFcmToken(token);
      return status;
    } catch (e) {
      debugPrint('Push permission request failed: $e');
      return AuthorizationStatus.denied;
    }
  }

  /// Call while signing out, before the session is torn down.
  ///
  /// Clearing the token server-side is what stops the daily sweep pushing this
  /// user's releases to a phone they've signed out of. Resetting [_started] is
  /// what lets the next account on this device register at all — otherwise
  /// [start] short-circuits for the rest of the app session and the new user
  /// silently never receives push.
  Future<void> stop() async {
    _cancelSubs();
    _started = false;

    try {
      // Backend first: it needs the session that sign-out is about to drop.
      await _userRepository.clearFcmToken();
      // Then drop the token locally, so the next sign-in registers a fresh one
      // rather than re-attaching the identifier the old account just released.
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      // Never block sign-out on this. A token left behind is pruned by the
      // send path once it goes stale.
      debugPrint('Push teardown skipped: $e');
    }
  }

  void dispose() => _cancelSubs();

  void _cancelSubs() {
    _tokenSub?.cancel();
    _foregroundSub?.cancel();
    _openedSub?.cancel();
    _tokenSub = null;
    _foregroundSub = null;
    _openedSub = null;
  }
}
