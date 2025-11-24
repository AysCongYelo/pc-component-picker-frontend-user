// frontend/lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================
// AUTH
// =============================
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/intro_screen.dart';

// =============================
// NAVIGATION
// =============================
import 'features/navigation/main_navigation.dart';

// =============================
// PROFILE
// =============================
import 'features/profile/screens/edit_profile_screen.dart';

// =============================
// HOME / FEATURED / AUTOBUILD
// =============================
import 'features/home/screens/featured_build_detail_screen.dart';
import 'features/home/screens/autobuild_result_screen.dart';
import 'features/home/providers/autobuild_provider.dart';

// =============================
// BUILD FLOW B (NEW)
// =============================
import 'features/build/screens/build_category_screen.dart';
import 'features/build/screens/build_components_screen.dart';

/// ==============================================
/// MAIN APP ROOT
/// ==============================================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCheck = ref.watch(hasTokenProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),

      home: authCheck.when(
        loading: () => const SplashScreen(),
        error: (_, __) => const LoginScreen(),
        data: (hasToken) {
          return hasToken ? MainNavigation() : const LoginScreen();
        },
      ),

      routes: {
        // =============================
        // AUTH ROUTES
        // =============================
        LoginScreen.routeName: (_) => const LoginScreen(),
        MainNavigation.routeName: (_) => MainNavigation(),
        IntroScreen.routeName: (_) => const IntroScreen(),

        // =============================
        // PROFILE
        // =============================
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),

        // =============================
        // FEATURED BUILD DETAIL
        // =============================
        FeaturedBuildDetailScreen.routeName: (ctx) => FeaturedBuildDetailScreen(
          featuredBuild:
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>,
        ),

        // =============================
        // AUTOBUILD RESULT SCREEN
        // =============================
        AutoBuildResultScreen.routeName: (ctx) {
          final result =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;

          return AutoBuildResultScreen(result: result);
        },

        // =============================
        // BUILD FLOW B (NEW)
        // =============================
        BuildCategoryScreen.routeName: (_) => const BuildCategoryScreen(),
        BuildComponentsScreen.routeName: (_) => const BuildComponentsScreen(),
      },
    );
  }
}
