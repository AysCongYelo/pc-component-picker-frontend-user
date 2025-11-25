// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user; // Map<String, dynamic> or null

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _headerCard(context, user),
              const SizedBox(height: 24),

              _section("Account"),
              const SizedBox(height: 12),

              _menu(
                icon: Icons.history,
                title: "Order History",
                subtitle: "View your past orders",
                onTap: () {},
              ),
              _menu(
                icon: Icons.bookmark,
                title: "Saved Builds",
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
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER CARD
  // ---------------------------------------------------------------------------
  Widget _headerCard(BuildContext context, Map<String, dynamic>? user) {
    final mainBlue = const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
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
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: user?['avatar_url'] != null
                ? NetworkImage(user!['avatar_url'])
                : const AssetImage('assets/user.png') as ImageProvider,
          ),

          const SizedBox(height: 16),

          Text(
            user?['full_name'] ?? "Unknown User",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user?['email'] ?? "",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, EditProfileScreen.routeName);
              },
              icon: const Icon(Icons.edit, size: 18),
              style: ElevatedButton.styleFrom(
                foregroundColor: mainBlue,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------
  Widget _section(String title) {
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

  // ---------------------------------------------------------------------------
  // MENU ITEM
  // ---------------------------------------------------------------------------
  Widget _menu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF2563EB), size: 26),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT BUTTON (THIS WAS THE MISSING FUNCTION)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // LOGOUT CONFIRMATION
  // ---------------------------------------------------------------------------
  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
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
              Navigator.pop(dialogCtx);

              await ref.read(authProvider.notifier).logout();

              if (!context.mounted) return;

              Navigator.of(context).pushNamedAndRemoveUntil(
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
