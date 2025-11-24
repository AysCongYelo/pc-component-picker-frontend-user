import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/autobuild_service.dart';

final autoBuildProvider =
    StateNotifierProvider<AutoBuildNotifier, AsyncValue<Map<String, dynamic>>>(
      (ref) => AutoBuildNotifier(AutoBuildService()),
    );

class AutoBuildNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AutoBuildService service;

  AutoBuildNotifier(this.service) : super(const AsyncValue.data({}));

  Future<void> generateAutoBuild({
    required String purpose,
    required double budget,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await service.autoBuild(purpose: purpose, budget: budget);

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
