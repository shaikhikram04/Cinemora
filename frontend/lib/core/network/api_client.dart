import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
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
