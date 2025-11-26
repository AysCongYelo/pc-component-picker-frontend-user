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

    // IMPORTANT: No more const — prevents login bypass
    final pages = [
      HomeScreen(),
      BuildTab(),
      SavedBuildsPage(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Build"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saves"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
