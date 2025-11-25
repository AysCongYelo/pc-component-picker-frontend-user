import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildPremiumHeaderCard(context, state, ref),
              const SizedBox(height: 24),

              _buildSectionHeader("Account"),
              const SizedBox(height: 12),

              _buildMenuItem(
                context,
                icon: Icons.history,
                label: "Order History",
                subtitle: "View your past orders",
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.bookmark,
                label: "Saved Builds",
                subtitle: "Your custom PC configurations",
                onTap: () {},
              ),

              const SizedBox(height: 32),

              _buildLogoutButton(context, ref),

              const SizedBox(height: 20),
              Text(
                "Version 1.0.0",
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  // HEADER CARD
  // ================================
  Widget _buildPremiumHeaderCard(
    BuildContext context,
    ProfileState state,
    WidgetRef ref,
  ) {
    final Color mainBlue = const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: _buildAvatar(state),
            ),
          ),

          const SizedBox(height: 16),

          _buildName(state),
          const SizedBox(height: 4),
          _buildEmail(state),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, EditProfileScreen.routeName);
                ref.read(profileProvider.notifier).loadProfile();
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: mainBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // AVATAR
  // ================================
  Widget _buildAvatar(ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFFDCECFF),
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }

    if (state.status == ProfileStatus.error || state.profile == null) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.error, size: 50, color: Colors.red),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color(0xFFDCECFF),
      backgroundImage: state.profile!.avatarUrl != null
          ? NetworkImage(state.profile!.avatarUrl!)
          : const AssetImage('assets/default_profile.png') as ImageProvider,
    );
  }

  // ================================
  // NAME
  // ================================
  Widget _buildName(ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return const Text(
        "Loading...",
        style: TextStyle(color: Colors.white, fontSize: 20),
      );
    }

    return Text(
      state.profile?.fullName ?? "Unknown User",
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  // ================================
  // EMAIL
  // ================================
  Widget _buildEmail(ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return Text(
        "Please wait...",
        style: TextStyle(color: Colors.white.withOpacity(0.9)),
      );
    }

    return Text(
      state.profile?.email ?? "No email",
      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
    );
  }

  // ================================
  // SECTION HEADER
  // ================================
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ================================
  // MENU ITEM
  // ================================
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ================================
  // LOGOUT BUTTON
  // ================================
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, ref),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          "Logout",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ================================
  // LOGOUT CONFIRMATION DIALOG
  // ================================
  void _showLogoutConfirmation(BuildContext parentContext, WidgetRef ref) {
    showDialog(
      context: parentContext,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF97316),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx); // close dialog FIRST

              await ref.read(authProvider.notifier).logout();

              /// IMPORTANT FIX — use parent context
              Navigator.of(parentContext).pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFEF4444)),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
