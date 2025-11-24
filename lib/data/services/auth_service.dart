import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';

class AuthService {
  final ApiClient apiClient;
  AuthService(this.apiClient);

  /// LOGIN (NOW USING NAMED PARAMETERS)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final resp = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (resp['success'] != true) {
      throw Exception(resp['error'] ?? "Login failed");
    }

    final token = resp['token'];
    final refresh = resp['refresh_token'];
    final user = resp['user'];

    if (token == null) {
      throw Exception("Login response missing token");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    if (refresh != null) {
      await prefs.setString('refresh_token', refresh);
    }

    return {
      'success': true,
      'token': token,
      'refresh_token': refresh,
      'user': user,
    };
  }

  /// SIGNUP (NOW USING NAMED PARAMETERS & RETURNS FULL TOKEN + USER)
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final resp = await apiClient.post('/auth/signup', {
      "full_name": fullName,
      "email": email,
      "password": password,
    });

    // Backend returns: success, user, message
    // BUT we need to handle token assignment later in provider
    return resp;
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }
}
