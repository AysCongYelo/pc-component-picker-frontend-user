import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';

/// PROFILE MODEL (simple structure)
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      avatarUrl: map['avatar_url'],
      createdAt: map['created_at'],
    );
  }
}

/// STATE ENUM
enum ProfileStatus { loading, loaded, error }

/// STATE CLASS
class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? error;

  ProfileState({required this.status, this.profile, this.error});

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }

  factory ProfileState.loading() => ProfileState(status: ProfileStatus.loading);

  factory ProfileState.error(String msg) =>
      ProfileState(status: ProfileStatus.error, error: msg);

  factory ProfileState.loaded(UserProfile u) =>
      ProfileState(status: ProfileStatus.loaded, profile: u);
}

/// PROVIDER NOTIFIER
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service = ProfileService();

  ProfileNotifier() : super(ProfileState.loading()) {
    loadProfile(); // Auto load when provider starts
  }

  Future<void> loadProfile() async {
    try {
      state = ProfileState.loading();

      final data = await _service.getMyProfile();
      final profile = UserProfile.fromMap(data);

      state = ProfileState.loaded(profile);
    } catch (e) {
      state = ProfileState.error(e.toString());
    }
  }

  Future<void> updateName(String fullName) async {
    try {
      await _service.updateProfile(fullName);
      await loadProfile(); // refresh
    } catch (e) {
      state = ProfileState.error(e.toString());
    }
  }

  Future<void> updateAvatar(File file) async {
    try {
      await _service.updateAvatar(file);
      await loadProfile(); // refresh
    } catch (e) {
      state = ProfileState.error(e.toString());
    }
  }
}

/// PUBLIC PROVIDER
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
