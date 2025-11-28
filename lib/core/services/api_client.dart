import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient.create() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.backendUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        // VERY IMPORTANT
        validateStatus: (status) => true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Helper to return backend error safely
  dynamic _handleResponse(Response res) {
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception(
        res.data is Map
            ? res.data["message"] ?? res.data.toString()
            : res.data.toString(),
      );
    }
    return res.data;
  }

  Future<dynamic> get(String path) async {
    final res = await _dio.get(path);
    return _handleResponse(res);
  }

  Future<dynamic> post(String path, dynamic data) async {
    final res = await _dio.post(path, data: data);
    return _handleResponse(res);
  }

  Future<dynamic> patch(String path, dynamic data) async {
    final res = await _dio.patch(path, data: data);
    return _handleResponse(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await _dio.delete(path);
    return _handleResponse(res);
  }

  Future<dynamic> put(String path, dynamic data) async {
    final res = await _dio.put(path, data: data);
    return _handleResponse(res);
  }
}
