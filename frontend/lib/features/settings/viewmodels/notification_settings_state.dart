import 'package:equatable/equatable.dart';

enum NotificationSettingsStatus { loading, ready }

class NotificationSettingsState extends Equatable {
  final NotificationSettingsStatus status;

  /// Push-channel toggles, persisted on the user document. The in-app inbox
  /// always fills regardless — these only gate the daily FCM push.
  final bool pushNewRelease;
  final bool pushNewSeason;

  const NotificationSettingsState({
    this.status = NotificationSettingsStatus.loading,
    this.pushNewRelease = true,
    this.pushNewSeason = true,
  });

  /// The group's master switch: on when any push type is on; turning it off
  /// silences everything at once.
  bool get masterEnabled => pushNewRelease || pushNewSeason;

  NotificationSettingsState copyWith({
    NotificationSettingsStatus? status,
    bool? pushNewRelease,
    bool? pushNewSeason,
  }) =>
      NotificationSettingsState(
        status: status ?? this.status,
        pushNewRelease: pushNewRelease ?? this.pushNewRelease,
        pushNewSeason: pushNewSeason ?? this.pushNewSeason,
      );

  @override
  List<Object> get props => [status, pushNewRelease, pushNewSeason];
}
