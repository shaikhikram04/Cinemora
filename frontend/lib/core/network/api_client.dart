import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../exceptions/app_exception.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  late final Dio _plainDio; // no interceptors — used only for token refresh
  late final Dio _probeDio; // no interceptors, short timeout — health checks

  /// Emits `true` whenever the server is demonstrably reachable and `false`
  /// whenever a request dies before reaching it. Fed by every request the app
  /// already makes, so reachability is inferred for free — see
  /// [_ConnectivityInterceptor]. [NetworkStatusCubit] is the consumer.
  final _connectivity = StreamController<bool>.broadcast();

  Stream<bool> get connectivityEvents => _connectivity.stream;

  ApiClient(SecureStorageService storage) {
    _plainDio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'ngrok-skip-browser-warning': 'true'},
    ));

    // Short timeouts on purpose: a probe that takes 15s to fail would stretch
    // the reconnect backoff far past its scheduled interval.
    _probeDio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: {'ngrok-skip-browser-warning': 'true'},
    ));

    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'ngrok-skip-browser-warning': 'true'},
    ));

    if (kDebugMode) dio.interceptors.add(_LogInterceptor());
    dio.interceptors.add(_ConnectivityInterceptor(_connectivity));
    dio.interceptors.add(_AuthInterceptor(storage, _plainDio));
  }

  /// Asks the server directly whether it can be reached. Used only while the
  /// app already believes it is offline — nothing polls while healthy.
  Future<bool> probe() async {
    try {
      await _probeDio.get('/health');
      _connectivity.add(true);
      return true;
    } catch (_) {
      _connectivity.add(false);
      return false;
    }
  }

  void dispose() => _connectivity.close();

  /// Converts any caught error into a typed [AppException].
  /// Call this in catch blocks in services and repositories.
  static AppException parseError(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException('NETWORK_TIMEOUT');
        case DioExceptionType.connectionError:
          return const NetworkException('NETWORK_NO_CONNECTION');
        default:
          break;
      }

      final data = error.response?.data;
      if (data is Map<String, dynamic> &&
          data['error'] is Map<String, dynamic>) {
        final errMap = data['error'] as Map<String, dynamic>;
        final code = errMap['code'] as String? ?? 'UNKNOWN';
        final message = errMap['message'] as String?;
        return BackendException(code, message);
      }
    }

    return const NetworkException();
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    dev.log('[API] --> ${options.method} ${options.baseUrl}${options.path}'
        '${options.queryParameters.isNotEmpty ? '?${options.queryParameters}' : ''}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log('[API] <-- ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log('[API] ERR ${err.requestOptions.path} '
        '— type: ${err.type}, status: ${err.response?.statusCode}, '
        'msg: ${err.message}');
    handler.next(err);
  }
}

/// Turns ordinary request traffic into a reachability signal, so the app learns
/// it is offline from work it was doing anyway rather than from polling.
class _ConnectivityInterceptor extends Interceptor {
  final StreamController<bool> _sink;

  _ConnectivityInterceptor(this._sink);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _sink.add(true);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A 4xx/5xx means the server answered — that's proof of reachability, and
    // must not be mistaken for being offline.
    _sink.add(!_isTransportFailure(err));
    handler.next(err);
  }

  bool _isTransportFailure(DioException err) => switch (err.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          true,
        _ => false,
      };
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _plainDio;
  bool _isRefreshing = false;
  final List<Completer<String>> _queue = [];

  _AuthInterceptor(this._storage, this._plainDio);

  /// A FormData body is a single-use stream: it was already consumed by the
  /// request that 401'd, so replaying it verbatim uploads an empty body. Clone
  /// it (multipart files are re-read from their path) before retrying.
  RequestOptions _replayable(RequestOptions opts, String token) {
    opts.headers['Authorization'] = 'Bearer $token';
    if (opts.data is FormData) {
      opts.data = (opts.data as FormData).clone();
    }
    return opts;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // A refresh is already in flight — queue this request and wait for the
      // new token rather than propagating the 401 immediately.
      final completer = Completer<String>();
      _queue.add(completer);
      try {
        final newToken = await completer.future;
        handler.resolve(
          await _plainDio.fetch(_replayable(err.requestOptions, newToken)),
        );
      } on DioException catch (replayError) {
        handler.next(replayError);
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    final String newToken;
    try {
      newToken = await _refreshAccessToken();
    } catch (refreshError) {
      // Only a refresh the server actually turned down means the session is
      // dead. A timeout or a connection error says nothing about the session,
      // and dropping the tokens there would sign the user out over a slow
      // network.
      if (_isSessionRejected(refreshError)) await _storage.clearSession();
      for (final c in _queue) {
        c.completeError('refresh failed');
      }
      _queue.clear();
      _isRefreshing = false;
      handler.next(err);
      return;
    }

    for (final c in _queue) {
      c.complete(newToken);
    }
    _queue.clear();
    _isRefreshing = false;

    // Replayed outside the block above on purpose: if the original request
    // fails again — a slow endpoint blowing its receiveTimeout, say — that is a
    // failure of that request, not of the session we just refreshed.
    try {
      handler.resolve(
        await _plainDio.fetch(_replayable(err.requestOptions, newToken)),
      );
    } on DioException catch (replayError) {
      handler.next(replayError);
    }
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) throw const _NoRefreshToken();

    final res = await _plainDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final newToken = res.data['accessToken'] as String;
    await _storage.saveAccessToken(newToken);
    return newToken;
  }

  bool _isSessionRejected(Object error) {
    if (error is _NoRefreshToken) return true;
    final status = error is DioException ? error.response?.statusCode : null;
    return status == 401 || status == 403;
  }
}

/// There is no stored refresh token, so there is no session left to renew.
class _NoRefreshToken implements Exception {
  const _NoRefreshToken();
}
