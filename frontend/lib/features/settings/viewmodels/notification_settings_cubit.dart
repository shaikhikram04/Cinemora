import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'notification_settings_state.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final UserRepository _userRepository;

  NotificationSettingsCubit(this._userRepository)
      : super(const NotificationSettingsState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await _userRepository.getNotificationPrefs();
      emit(NotificationSettingsState(
        status: NotificationSettingsStatus.ready,
        pushNewRelease: prefs.pushNewRelease,
        pushNewSeason: prefs.pushNewSeason,
      ));
    } catch (_) {
      // Show the defaults rather than a dead screen; the first toggle the
      // user flips will persist the real state.
      emit(state.copyWith(status: NotificationSettingsStatus.ready));
    }
  }

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
