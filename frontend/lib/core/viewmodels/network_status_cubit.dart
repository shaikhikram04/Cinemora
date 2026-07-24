import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../network/api_client.dart';

enum NetworkStatus {
  online,

  /// The last request died before reaching the server.
  offline,

  /// Transient — we just came back. Exists so the banner can say "Back online"
  /// before it disappears; collapses to [online] on its own.
  restored,
}

/// Tracks whether the API is reachable, without asking the OS about the radio.
///
/// Status comes from two sources: every request the app already makes (via
/// [ApiClient.connectivityEvents]), and — only while offline — a backoff probe
/// against `/health`. Nothing polls while healthy, so the common case costs
/// nothing.
class NetworkStatusCubit extends Cubit<NetworkStatus> {
  final ApiClient _apiClient;

  late final StreamSubscription<bool> _sub;
  Timer? _probeTimer;
  Timer? _restoredTimer;
  int _attempt = 0;

  /// Fires on every offline→online edge. Screens sitting on a failure state
  /// listen to this and re-fetch, so recovery doesn't need a manual tap.
  final _reconnect = StreamController<void>.broadcast();

  Stream<void> get onReconnect => _reconnect.stream;

  bool get isOffline => state == NetworkStatus.offline;

  static const _backoff = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
  ];

  static const _restoredDuration = Duration(seconds: 2);

  NetworkStatusCubit(this._apiClient) : super(NetworkStatus.online) {
    _sub = _apiClient.connectivityEvents.listen(_report);
  }

  void _report(bool reachable) => reachable ? _markOnline() : _markOffline();

  void _markOffline() {
    _restoredTimer?.cancel();
    if (state == NetworkStatus.offline) return;
    emit(NetworkStatus.offline);
    _attempt = 0;
    _scheduleProbe();
  }

  void _markOnline() {
    _probeTimer?.cancel();
    _probeTimer = null;
    _attempt = 0;

    // Nothing to announce if we were never down. Note `restored` also counts as
    // already-online, so a burst of successful requests can't restart the timer
    // and leave the banner stuck.
    if (state == NetworkStatus.online || state == NetworkStatus.restored) {
      return;
    }

    emit(NetworkStatus.restored);
    _reconnect.add(null);
    _restoredTimer?.cancel();
    _restoredTimer = Timer(_restoredDuration, () {
      if (!isClosed && state == NetworkStatus.restored) {
        emit(NetworkStatus.online);
      }
    });
  }

  void _scheduleProbe() {
    _probeTimer?.cancel();
    final delay = _backoff[_attempt.clamp(0, _backoff.length - 1)];
    _probeTimer = Timer(delay, () async {
      if (isClosed || state != NetworkStatus.offline) return;
      _attempt++;
      // probe() feeds the same stream we listen to, so a success lands in
      // _markOnline and cancels the loop. Only reschedule if it didn't.
      final reachable = await _apiClient.probe();
      if (!isClosed && !reachable && state == NetworkStatus.offline) {
        _scheduleProbe();
      }
    });
  }

  /// Lets a Retry button ask right now instead of waiting out the backoff.
  Future<void> checkNow() => _apiClient.probe();

  @override
  Future<void> close() {
    _sub.cancel();
    _probeTimer?.cancel();
    _restoredTimer?.cancel();
    _reconnect.close();
    return super.close();
  }
}
