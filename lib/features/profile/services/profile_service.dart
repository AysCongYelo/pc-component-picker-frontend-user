import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  // GET PROFILE
  Future<Map<String, dynamic>> getMyProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw "Not logged in";

    final res = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (res == null) throw "Profile not found";
    return res;
  }

  // UPDATE NAME
  Future<bool> updateProfile(String fullName) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw "Not logged in";

    await supabase
        .from('profiles')
        .update({'full_name': fullName})
        .eq('id', user.id);

    return true;
  }

  // UPDATE AVATAR
  Future<bool> updateAvatar(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw "Not logged in";

    final fileName = "avatar-${user.id}.jpg";

    // Upload to storage bucket
    await supabase.storage
        .from('avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    // Generate public URL
    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

    // Save to profile table
    await supabase
        .from('profiles')
        .update({'avatar_url': publicUrl})
        .eq('id', user.id);

    return true;
  }
}
