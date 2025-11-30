import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Temporary build provider (auto-build results or loaded saved build)
/// // ✅ Flag: galing ba sa Home Auto Build?
final autoBuildFromHomeProvider = StateProvider<bool>((ref) => false);
final buildProvider =
    StateNotifierProvider<BuildNotifier, Map<String, dynamic>?>(
      (ref) => BuildNotifier(),
    );

class BuildNotifier extends StateNotifier<Map<String, dynamic>?> {
  BuildNotifier() : super(null);

  void setTempBuild(Map<String, dynamic> build) {
    state = build;
  }

  void reset() => state = null;
}
