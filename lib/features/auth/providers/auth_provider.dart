import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/api_client.dart';
import '../services/auth_service.dart';

/// ==============================================================
/// API CLIENT PROVIDER
/// ==============================================================
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create();
});

/// ==============================================================
/// AUTH STATE
/// ==============================================================
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final Map<String, dynamic>? user;
  final String? token;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
    this.token,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    Map<String, dynamic>? user,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

/// ==============================================================
/// AUTH NOTIFIER (BFF PATCHED VERSION)
/// ==============================================================
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService)
    : super(AuthState(isAuthenticated: false, isLoading: true)) {
    _init();
  }

  // ============================================================
  // INIT — Auto Login Fix (No Ghost Login)
  // ============================================================
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("auth_token");
    final refresh = prefs.getString("refresh_token");

    // No token? user is logged out
    if (token == null || token.isEmpty) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
      return;
    }

    // Use stored token
    authService.apiClient.setAuthToken(token);

    // Try validating token by calling /auth/me
    final me = await authService.getMe();

    if (me["success"] == true) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
        user: me["user"],
      );
      return;
    }

    // If /me failed, try refresh
    if (refresh != null && refresh.isNotEmpty) {
      final ok = await _tryRefresh(refresh);
      if (ok) return;
    }

    // Both failed → force logout
    await logout();
  }

  // ============================================================
  // Try Refresh Token
  // ============================================================
  Future<bool> _tryRefresh(String refreshToken) async {
    final res = await authService.refreshToken(refreshToken);

    if (res["success"] != true) return false;

    final newToken = res["token"];
    final newRefresh = res["refresh_token"];

    if (newToken == null) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", newToken);
    await prefs.setString("refresh_token", newRefresh ?? "");

    authService.apiClient.setAuthToken(newToken);

    // Validate new token
    final me = await authService.getMe();

    if (me["success"] != true) return false;

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      token: newToken,
      user: me["user"],
    );

    return true;
  }

  // ============================================================
  // LOGIN
  // ============================================================
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);

    final res = await authService.login(email: email, password: password);

    if (res["success"] != true) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    final token = res["token"];
    final refresh = res["refresh_token"];

    if (token == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setString("refresh_token", refresh ?? "");

    authService.apiClient.setAuthToken(token);

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      token: token,
      user: res["user"],
    );

    return true;
  }

  // ============================================================
  // LOGOUT (FULL CLEAN)
  // ============================================================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("refresh_token");

    authService.apiClient.clearAuth();

    state = AuthState(
      isAuthenticated: false,
      isLoading: false,
      user: null,
      token: null,
    );
  }
}

/// ==============================================================
/// AUTH PROVIDER
/// ==============================================================
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.read(apiClientProvider);
  return AuthNotifier(AuthService(api));
});
