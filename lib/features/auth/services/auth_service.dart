import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/env.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// LOGIN
  Future<bool> login(String email, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    // FIX: token key
    final token = res.data['token'] ?? res.data['accessToken'];

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }

    return false;
  }

  /// REGISTER
  Future<bool> register(String email, String password) async {
    final res = await _dio.post(
      '/auth/signup', // FIXED ROUTE
      data: {'email': email, 'password': password},
    );

    return res.data['success'] == true;
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
