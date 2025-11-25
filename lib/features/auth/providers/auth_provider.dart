import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final Map<String, dynamic>? user;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isAuthenticated: false, isLoading: true)) {
    // IMPORTANT FIX: run init AFTER first frame
    Future.microtask(() => _init());
  }

  final supabase = Supabase.instance.client;

  Future<void> _init() async {
    // Smooth startup (prevents Android hang)
    await Future.delayed(const Duration(milliseconds: 120));

    final session = supabase.auth.currentSession;

    if (session != null) {
      final profile = await _loadProfile(session.user.id);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: profile,
      );
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }

    // AUTH STATE LISTENER (login, logout, refresh)
    supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;

      if (session == null) {
        state = state.copyWith(isAuthenticated: false, user: null);
        return;
      }

      final profile = await _loadProfile(session.user.id);
      state = state.copyWith(isAuthenticated: true, user: profile);
    });
  }

  Future<Map<String, dynamic>?> _loadProfile(String uid) async {
    final res = await supabase
        .from("profiles")
        .select()
        .eq("id", uid)
        .maybeSingle();

    return res;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      state = state.copyWith(isLoading: true);

      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // if failed, res.session will be null → return false
      if (res.session == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final profile = await _loadProfile(res.session!.user.id);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: profile,
      );

      return true;
    } catch (e) {
      // prevent crash
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    state = AuthState(isAuthenticated: false, isLoading: false, user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
