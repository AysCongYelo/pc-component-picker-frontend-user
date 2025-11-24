import 'package:dio/dio.dart';
import 'package:frontend/core/constants/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoBuildService {
  late Dio _dio;

  AutoBuildService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    // Auto-attach token (backup)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // ============================================================
  // POST /builder/autobuild
  // ============================================================
  Future<Map<String, dynamic>> autoBuild({
    required String purpose,
    required double budget,
  }) async {
    // ⭐ your requested addition (manual header)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _dio.post(
      '/builder/autobuild',
      data: {"purpose": purpose, "budget": budget},
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );

    return response.data;
  }
}
