import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/core/services/api_client_provider.dart';
import '../services/auto_build_service.dart';
import '../../build/providers/build_provider.dart';

final autoBuildProvider =
    StateNotifierProvider<AutoBuildNotifier, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      final api = ref.read(apiClientProvider);
      return AutoBuildNotifier(ref, AutoBuildService(api));
    });

class AutoBuildNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Ref ref;
  final AutoBuildService service;

  AutoBuildNotifier(this.ref, this.service) : super(const AsyncValue.data({}));

  Future<void> generateAutoBuild({
    required String purpose,
    required double budget,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await service.autoBuild(
        purpose: purpose,
        budget: budget,
      );

      final build = Map<String, dynamic>.from(response['build'] ?? {});
      final summary = Map<String, dynamic>.from(response['summary'] ?? {});

      if (build.isEmpty) {
        throw Exception("❌ Backend returned no build data.");
      }

      // 🔥 Update Build Provider instantly (super fast UI)
      ref.read(buildProvider.notifier).setTempBuild(build, summary);

      // Update local state for AutoBuild UI
      state = AsyncValue.data({"build": build, "summary": summary});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
