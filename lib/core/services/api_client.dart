import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/env.dart';

class ApiClient {
  late final Dio _dio;
  String? _manualToken; // token controlled by AuthNotifier

  ApiClient.create() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Duration.zero,
        receiveTimeout: Duration.zero,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1) Manual token (highest priority)
          if (_manualToken != null) {
            options.headers['Authorization'] = 'Bearer $_manualToken';
            return handler.next(options);
          }

          // 2) Fallback token from storage
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (err, handler) async {
          if (err.response?.statusCode != 401) {
            return handler.next(err); // only refresh on 401
          }

          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString("refresh_token");

          if (refreshToken == null) {
            return handler.next(err);
          }

          try {
            // USE CLEAN INSTANCE WITHOUT INTERCEPTORS
            final refreshDio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

            final refreshRes = await refreshDio.post(
              '/auth/refresh',
              data: {"refresh_token": refreshToken},
            );

            final newToken = refreshRes.data['token'];
            final newRefresh = refreshRes.data['refresh_token'];

            if (newToken == null) {
              return handler.next(err);
            }

            // Save tokens
            await prefs.setString('auth_token', newToken);
            if (newRefresh != null) {
              await prefs.setString('refresh_token', newRefresh);
            }

            // Set manual override token
            _manualToken = newToken;

            // Retry original request
            final req = err.requestOptions;
            req.headers['Authorization'] = 'Bearer $newToken';

            final retryResponse = await _dio.fetch(req);
            return handler.resolve(retryResponse);
          } catch (_) {
            return handler.next(err); // Refresh failed
          }
        },
      ),
    );
  }

  /// ================================================================
  /// MANUAL TOKEN SET (used by AuthNotifier on login)
  /// ================================================================
  void setAuthToken(String? token) {
    _manualToken = token;
  }

  /// ================================================================
  /// CLEAR TOKEN ON LOGOUT (needed by your provider)
  /// ================================================================
  void clearAuth() {
    _manualToken = null;
  }

  /// ================================================================
  /// BASIC REQUEST HELPERS
  /// ================================================================
  Future<dynamic> get(String path) async {
    final res = await _dio.get(path);
    return res.data;
  }

  Future<dynamic> post(String path, dynamic data) async {
    final res = await _dio.post(path, data: data);
    return res.data;
  }

  Future<dynamic> patch(String path, dynamic data) async {
    final res = await _dio.patch(path, data: data);
    return res.data;
  }

  Future<dynamic> delete(String path) async {
    final res = await _dio.delete(path);
    return res.data;
  }
}
