import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_client.dart';
import '../../../data/services/auth_service.dart';

/// PROVIDE ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create();
});

/// AUTH STATE
class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? token;

  AuthState({required this.isAuthenticated, this.user, this.token});

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

/// AUTH NOTIFIER
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService)
    : super(AuthState(isAuthenticated: false, user: null, token: null)) {
    _init();
  }

  /// INITIALIZE TOKEN + USER (Auto Login)
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token != null && token.isNotEmpty) {
      // Attach token manually to ApiClient
      authService.apiClient.setAuthToken(token);

      // Load user (/auth/me)
      final me = await authService.getMe();

      if (me["success"] == true) {
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: me["user"],
        );
      } else {
        await logout();
      }
    }
  }

  /// LOGIN
  Future<bool> login({required String email, required String password}) async {
    final res = await authService.login(email: email, password: password);

    if (res["success"] == true) {
      final token = res["token"];
      final refreshToken = res["refresh_token"];
      final user = res["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
      if (refreshToken != null) {
        await prefs.setString("refresh_token", refreshToken);
      }

      authService.apiClient.setAuthToken(token);

      state = state.copyWith(isAuthenticated: true, token: token, user: user);

      return true;
    }
    return false;
  }

  /// SIGNUP
  Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await authService.signup(
      fullName: fullName,
      email: email,
      password: password,
    );

    return res["success"] == true;
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("refresh_token");

    authService.apiClient.setAuthToken(null);

    state = AuthState(isAuthenticated: false, user: null, token: null);
  }
}

/// PROVIDER
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.read(apiClientProvider);
  final service = AuthService(api);
  return AuthNotifier(service);
});

/// CHECK TOKEN ON START
final hasTokenProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("auth_token");
  return token != null && token.isNotEmpty;
});
