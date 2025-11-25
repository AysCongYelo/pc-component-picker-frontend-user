import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/providers/auth_provider.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const routeName = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _nameController = TextEditingController();

  File? _newAvatar;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user["full_name"] ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final p = await _picker.pickImage(source: source);
    if (p != null) {
      setState(() => _newAvatar = File(p.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final service = ProfileService();
    final notifier = ref.read(authProvider.notifier);

    try {
      // update name
      await service.updateProfile(_nameController.text.trim());

      // update avatar
      if (_newAvatar != null) {
        await service.updateAvatar(_newAvatar!);
      }

      // refresh authProvider's user data
      await notifier.refreshUserProfile();

      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _newAvatar != null
                              ? FileImage(_newAvatar!)
                              : (user["avatar_url"] != null
                                        ? NetworkImage(user["avatar_url"])
                                        : const AssetImage("assets/user.png"))
                                    as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              onPressed: () => _chooseSource(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Name required"
                          : null,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _chooseSource() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change avatar"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            child: const Text("Camera"),
            onPressed: () {
              Navigator.pop(context);
              _pick(ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text("Gallery"),
            onPressed: () {
              Navigator.pop(context);
              _pick(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
