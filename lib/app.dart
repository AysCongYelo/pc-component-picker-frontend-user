// frontend/lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================
// AUTH
// =============================
import '../../../features/auth/providers/auth_provider.dart';
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),

      home: Builder(
        builder: (_) {
          if (auth.isLoading) {
            return const SplashScreen();
          }

          if (auth.isAuthenticated) {
            return MainNavigation();
          }

          return const LoginScreen();
        },
      ),

      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        MainNavigation.routeName: (_) => const MainNavigation(),
        IntroScreen.routeName: (_) => const IntroScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),

        // FEATURED DETAILS
        FeaturedBuildDetailScreen.routeName: (ctx) => FeaturedBuildDetailScreen(
          featuredBuild:
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>,
        ),

        // AUTOBUILD RESULT
        AutoBuildResultScreen.routeName: (ctx) {
          final result =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
          return AutoBuildResultScreen(result: result);
        },

        // BUILD FLOW
        BuildCategoryScreen.routeName: (_) => const BuildCategoryScreen(),
        BuildComponentsScreen.routeName: (_) => const BuildComponentsScreen(),
      },
    );
  }
}
