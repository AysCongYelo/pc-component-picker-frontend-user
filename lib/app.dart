// frontend/lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AUTH
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/intro_screen.dart';

// NAVIGATION
import 'features/navigation/main_navigation.dart';

// PROFILE
import 'features/profile/screens/edit_profile_screen.dart';

// HOME / FEATURED / AUTOBUILD
import 'features/home/screens/featured_build_detail_screen.dart';
import 'features/home/screens/autobuild_result_screen.dart';

// BUILD FLOW B (NEW)
import 'features/build/screens/build_category_screen.dart';
import 'features/build/screens/build_components_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),

      // Choose first screen depending on auth state
      home: Builder(
        builder: (_) {
          if (auth.isLoading) return const SplashScreen();
          if (auth.isAuthenticated) return const MainNavigation();
          return const LoginScreen();
        },
      ),

      routes: {
        // AUTH & NAV
        LoginScreen.routeName: (_) => const LoginScreen(),
        MainNavigation.routeName: (_) => const MainNavigation(),
        IntroScreen.routeName: (_) => const IntroScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),

        // FEATURED BUILD DETAILS (no constructor args)
        FeaturedBuildDetailScreen.routeName: (ctx) =>
            const FeaturedBuildDetailScreen(),

        // AUTOBUILD RESULT SCREEN
        AutoBuildResultScreen.routeName: (ctx) {
          final result =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
          return AutoBuildResultScreen(result: result);
        },
      },
    );
  }
}
