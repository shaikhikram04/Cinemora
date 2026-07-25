import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/services/push_notifications_service.dart';
import 'notification_settings_state.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final UserRepository _userRepository;
  final PushNotificationsService _pushService;

  NotificationSettingsCubit(this._userRepository, this._pushService)
      : super(const NotificationSettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final permission = await _readPermission();
    try {
      final prefs = await _userRepository.getNotificationPrefs();
      emit(NotificationSettingsState(
        status: NotificationSettingsStatus.ready,
        pushNewRelease: prefs.pushNewRelease,
        pushNewSeason: prefs.pushNewSeason,
        permission: permission,
      ));
    } catch (_) {
      // Show the defaults rather than a dead screen; the first toggle the
      // user flips will persist the real state.
      emit(state.copyWith(
        status: NotificationSettingsStatus.ready,
        permission: permission,
      ));
    }
  }

  /// Re-reads the OS permission — called when the screen comes back to the
  /// foreground, since the user may have changed it in system settings and
  /// nothing notifies the app when they do.
  Future<void> refreshPermission() async {
    final permission = await _readPermission();
    if (!isClosed) emit(state.copyWith(permission: permission));
  }

  /// Shows the OS prompt and registers the token if it's granted. Only offered
  /// while [PushPermission.askable]; once blocked, the screen sends the user
  /// to system settings instead.
  Future<void> requestPermission() async {
    if (state.isRequestingPermission) return;
    emit(state.copyWith(isRequestingPermission: true));

    final status = await _pushService.requestPermissionAndRegister();
    if (isClosed) return;

    emit(state.copyWith(
      permission: _map(status),
      isRequestingPermission: false,
    ));
  }

  Future<PushPermission> _readPermission() async =>
      _map(await _pushService.permissionStatus());

  static PushPermission _map(AuthorizationStatus status) => switch (status) {
        // Provisional (iOS quiet delivery) still reaches the user, just softly.
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional =>
          PushPermission.granted,
        AuthorizationStatus.denied => PushPermission.blocked,
        AuthorizationStatus.notDetermined => PushPermission.askable,
      };

  void setMaster(bool v) => _save(pushNewRelease: v, pushNewSeason: v);
  void setNewRelease(bool v) => _save(pushNewRelease: v);
  void setNewSeason(bool v) => _save(pushNewSeason: v);

  /// Optimistic: the switch flips immediately, and a failed save flips it
  /// back — a settings screen that lies about what's persisted is worse than
  /// a switch that visibly bounces.
  Future<void> _save({bool? pushNewRelease, bool? pushNewSeason}) async {
    final previous = state;
    emit(state.copyWith(
      pushNewRelease: pushNewRelease,
      pushNewSeason: pushNewSeason,
    ));
    try {
      await _userRepository.updateNotificationPrefs(
        pushNewRelease: pushNewRelease,
        pushNewSeason: pushNewSeason,
      );
    } catch (_) {
      emit(previous);
    }
  }
}
