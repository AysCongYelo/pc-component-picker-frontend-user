import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroNotifier extends AsyncNotifier<bool> {
  static const _key = 'has_seen_intro';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);

    // update provider state
    state = const AsyncData(true);
  }
}

final introProvider = AsyncNotifierProvider<IntroNotifier, bool>(
  () => IntroNotifier(),
);
