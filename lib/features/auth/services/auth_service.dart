import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ============================================================
  // LOGIN (SUPABASE)
  // ============================================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.session == null) {
      return {"success": false};
    }

    final userId = res.session!.user.id;

    final profile = await supabase
        .from("profiles")
        .select()
        .eq("id", userId)
        .maybeSingle();

    return {"success": true, "user": profile};
  }

  // ============================================================
  // SIGNUP (SUPABASE)
  // ============================================================
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {"full_name": fullName},
    );

    if (res.user == null) {
      return {"success": false};
    }

    // Optional: load profile
    return {"success": true, "user": res.user!.toJson()};
  }

  // ============================================================
  // GET CURRENT USER & PROFILE
  // ============================================================
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    final profile = await supabase
        .from("profiles")
        .select()
        .eq("id", session.user.id)
        .maybeSingle();

    return profile;
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
