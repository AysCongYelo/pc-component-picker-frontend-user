// lib/data/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/services/api_client.dart';
import 'package:frontend/core/constants/env.dart';

class AuthService {
  final ApiClient apiClient;
  final Dio _dio;

  AuthService(this.apiClient)
    : _dio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  /* ============================================================
      LOGIN
      -> Returns a Map with keys: success, token, refresh_token, user
  ============================================================ */
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );
      return Map<String, dynamic>.from(res.data ?? {"success": false});
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /* ============================================================
      SIGNUP
      -> Returns Map (success, maybe user or message)
  ============================================================ */
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        "/auth/signup",
        data: {"full_name": fullName, "email": email, "password": password},
      );
      return Map<String, dynamic>.from(res.data ?? {"success": false});
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /* ============================================================
      GET CURRENT USER (/auth/me)
      -> Uses ApiClient so interceptor attaches token
  ============================================================ */
  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await apiClient.get("/auth/me");
      return Map<String, dynamic>.from(res ?? {"success": false});
    } catch (e) {
      return {"success": false};
    }
  }

  /* ============================================================
      REFRESH TOKEN (/auth/refresh)
      -> Returns Map with new token(s)
  ============================================================ */
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final res = await apiClient.post("/auth/refresh", {
        "refresh_token": refreshToken,
      });
      return Map<String, dynamic>.from(res ?? {"success": false});
    } catch (e) {
      return {"success": false};
    }
  }

  /* ============================================================
      LOGOUT
      -> call backend logout (optional) and remove stored tokens
  ============================================================ */
  Future<void> logout() async {
    try {
      await apiClient.post("/auth/logout", {});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("refresh_token");
  }
}
