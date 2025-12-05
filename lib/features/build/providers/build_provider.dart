import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/features/build/services/build_service.dart';
import 'package:pc_component_picker/core/services/api_client_provider.dart';
import 'build_state.dart';

final buildProvider = AsyncNotifierProvider<BuildNotifier, BuildState>(
  BuildNotifier.new,
);

class BuildNotifier extends AsyncNotifier<BuildState> {
  late BuildService _service;

  @override
  Future<BuildState> build() async {
    _service = BuildService(ref.read(apiClientProvider));

    // initial load
    return await loadTempBuild();
  }

  // =========================
  // SET TEMP BUILD (instant UI update)
  // =========================
  void setTempBuild(Map<String, dynamic> build, Map<String, dynamic> summary) {
    state = AsyncData(
      BuildState(
        build: build,
        summary: summary,
        sourceBuildId: state.value?.sourceBuildId,
      ),
    );
  }

  // =========================
  // LOAD TEMP BUILD
  // =========================
  Future<BuildState> loadTempBuild() async {
    try {
      final res = await _service.loadTempBuild();
      return BuildState(
        build: res["build"] ?? {},
        summary: res["summary"] ?? {},
        sourceBuildId: res["source_build_id"],
      );
    } catch (e) {
      return BuildState(error: e.toString());
    }
  }

  // =========================
  // ADD COMPONENT
  // =========================
  Future<void> addComponent(String category, String id) async {
    state = const AsyncLoading();
    final res = await _service.addToTemp(category, id);

    state = AsyncData(
      state.value!.copyWith(build: res["build"], summary: res["summary"]),
    );
  }

  // =========================
  // REMOVE COMPONENT
  // =========================
  Future<void> removeComponent(String category) async {
    state = const AsyncLoading();
    final res = await _service.removeFromTemp(category);

    state = AsyncData(
      state.value!.copyWith(build: res["build"], summary: res["summary"]),
    );
  }

  // =========================
  // RESET BUILD
  // =========================
  Future<void> reset() async {
    state = const AsyncLoading();
    final res = await _service.resetTempBuild();

    state = AsyncData(
      BuildState(build: res["build"] ?? {}, summary: res["summary"] ?? {}),
    );
  }

  // =========================
  // AUTOCOMPLETE
  // =========================
  Future<void> autoComplete() async {
    state = const AsyncLoading();
    final res = await _service.autoComplete();

    state = AsyncData(
      BuildState(
        build: res["build"] ?? {},
        summary: res["summary"] ?? {},
        sourceBuildId: state.value!.sourceBuildId,
      ),
    );
  }

  // =========================
  // AUTOBUILD
  // =========================
  Future<void> autoBuild(String purpose, int budget) async {
    state = const AsyncLoading();
    final res = await _service.autoBuild(purpose, budget);

    state = AsyncData(
      BuildState(build: res["build"] ?? {}, summary: res["summary"] ?? {}),
    );
  }

  // =========================
  // SAVE BUILD
  // =========================
  Future<String?> save(String name) async {
    state = const AsyncLoading();
    final res = await _service.saveBuild(name: name);

    // backend clears temp build after saving
    state = const AsyncData(BuildState());
    return res["build"]["id"];
  }
}
