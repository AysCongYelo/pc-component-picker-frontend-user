import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'intro_screen.dart';
import 'login_screen.dart';
import '../../../features/navigation/main_navigation.dart'; // ✅ IMPORTANT

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final firstRun = prefs.getBool('first_run') ?? true;

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return; // SAFE

    if (firstRun) {
      await prefs.setBool('first_run', false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, IntroScreen.routeName);
      return;
    }

    // TOKEN CHECK
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, MainNavigation.routeName);
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstRun();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.computer, size: 80),
            SizedBox(height: 12),
            Text('PC Component Picker', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
