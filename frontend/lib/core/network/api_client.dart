import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../exceptions/app_exception.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  late final Dio _plainDio; // no interceptors — used only for token refresh

  ApiClient(SecureStorageService storage) {
    _plainDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    dio.interceptors.add(_AuthInterceptor(storage, _plainDio));
  }

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
      if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
        final errMap = data['error'] as Map<String, dynamic>;
        final code = errMap['code'] as String? ?? 'UNKNOWN';
        final message = errMap['message'] as String?;
        return BackendException(code, message);
      }
    }

    return const NetworkException();
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _plainDio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._storage, this._plainDio);

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
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) throw Exception('no refresh token');

        final res = await _plainDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        final newToken = res.data['accessToken'] as String;
        await _storage.saveAccessToken(newToken);

        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        final retried = await _plainDio.fetch(opts);
        handler.resolve(retried);
      } catch (_) {
        await _storage.clearAll();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}
