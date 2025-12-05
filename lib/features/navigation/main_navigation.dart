import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/screens/home_screen.dart';
import '../../features/build/screens/build_screen.dart';
import '../../features/save/screens/saved_builds_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

import 'providers/nav_provider.dart';

class MainNavigation extends ConsumerWidget {
  static const routeName = '/main-navigation';

  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    final pages = [
      const HomeScreen(),
      const BuildTab(),
      const SavedBuildsPage(),
      const ProfileScreen(),
    ];

    const Color mainBlue = Color(0xFF2563EB);
    const Color unselected = Color(0xFF94A3B8);

    return Scaffold(
      body: IndexedStack(index: index, children: pages),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: mainBlue,
          unselectedItemColor: unselected,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          elevation: 0,

          onTap: (i) {
            ref.read(navIndexProvider.notifier).state = i;
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_rounded),
              label: "Build",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.save_rounded),
              label: "Saves",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
