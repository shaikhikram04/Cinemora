import 'package:equatable/equatable.dart';

enum NotificationSettingsStatus { loading, ready }

/// OS-level permission, flattened to the three cases the screen reacts to.
enum PushPermission {
  /// The OS will deliver. Toggles mean what they say.
  granted,

  /// Never asked, or asked and dismissed — an in-app prompt can still work.
  askable,

  /// Hard denied. Only the system settings screen can undo it.
  blocked,
}

class NotificationSettingsState extends Equatable {
  final NotificationSettingsStatus status;

  /// Push-channel toggles, persisted on the user document. The in-app inbox
  /// always fills regardless — these only gate the daily FCM push.
  final bool pushNewRelease;
  final bool pushNewSeason;

  /// What the OS is actually willing to deliver. The toggles are a server-side
  /// preference and stay whatever the user set, but they are inert while this
  /// isn't [PushPermission.granted] — so the screen has to say so.
  final PushPermission permission;

  /// True while an in-app permission prompt is in flight.
  final bool isRequestingPermission;

  const NotificationSettingsState({
    this.status = NotificationSettingsStatus.loading,
    this.pushNewRelease = true,
    this.pushNewSeason = true,
    this.permission = PushPermission.granted,
    this.isRequestingPermission = false,
  });

  /// The group's master switch: on when any push type is on; turning it off
  /// silences everything at once.
  bool get masterEnabled => pushNewRelease || pushNewSeason;

  /// Whether flipping a switch can change what the user actually receives.
  bool get togglesAreLive => permission == PushPermission.granted;

  NotificationSettingsState copyWith({
    NotificationSettingsStatus? status,
    bool? pushNewRelease,
    bool? pushNewSeason,
    PushPermission? permission,
    bool? isRequestingPermission,
  }) =>
      NotificationSettingsState(
        status: status ?? this.status,
        pushNewRelease: pushNewRelease ?? this.pushNewRelease,
        pushNewSeason: pushNewSeason ?? this.pushNewSeason,
        permission: permission ?? this.permission,
        isRequestingPermission:
            isRequestingPermission ?? this.isRequestingPermission,
      );

  @override
  List<Object> get props => [
        status,
        pushNewRelease,
        pushNewSeason,
        permission,
        isRequestingPermission,
      ];
}
