// frontend/lib/features/build/services/build_service.dart
import 'package:frontend/core/services/api_client.dart';

class BuildService {
  final ApiClient api;
  BuildService(this.api);

  // ===============================
  // TEMP BUILD
  // ===============================

  Future<Map<String, dynamic>> loadTempBuild() async {
    final res = await api.get('/builder/temp');
    return {
      "build": res["build"] ?? {},
      "summary": res["summary"] ?? {},
      "source_build_id": res["source_build_id"],
    };
  }

  Future<Map<String, dynamic>> addToTemp(
    String category,
    String componentId,
  ) async {
    final res = await api.post('/builder/temp/add', {
      'category': category,
      'componentId': componentId,
    });

    return {"build": res["build"] ?? {}, "summary": res["summary"] ?? {}};
  }

  Future<Map<String, dynamic>> removeFromTemp(String category) async {
    final res = await api.post('/builder/temp/remove', {'category': category});

    return {"build": res["build"] ?? {}, "summary": res["summary"] ?? {}};
  }

  Future<Map<String, dynamic>> resetTempBuild() async {
    final res = await api.post('/builder/temp/reset', {});
    return {"build": res["build"] ?? {}, "summary": res["summary"] ?? {}};
  }

  // ===============================
  // COMPONENT PICKER
  // ===============================

  Future<List<dynamic>> fetchComponents(String category) async {
    final response = await api.get('/builder/components?category=$category');
    return response["components"] ?? [];
  }

  // ===============================
  // AUTO BUILDER
  // ===============================

  Future<Map<String, dynamic>> autoComplete() async {
    final res = await api.post('/builder/autocomplete', {});
    final data = res["data"] ?? res;

    return {"build": data["build"] ?? {}, "summary": data["summary"] ?? {}};
  }

  Future<Map<String, dynamic>> autoBuild(String purpose, int budget) async {
    final res = await api.post('/builder/autobuild', {
      'purpose': purpose,
      'budget': budget,
    });

    final data = res["data"] ?? res;

    return {"build": data["build"] ?? {}, "summary": data["summary"] ?? {}};
  }

  // ===============================
  // SAVED BUILDS
  // ===============================

  Future<Map<String, dynamic>> saveBuild({required String name}) async {
    final res = await api.post('/builder/save', {'name': name});
    return res;
  }

  Future<Map<String, dynamic>> loadSavedBuild(String id) async {
    final res = await api.post('/builder/load/$id', {});
    return {
      "build": res["build"] ?? {},
      "summary": res["summary"] ?? {},
      "source_build_id": res["source_build_id"],
    };
  }

  Future<Map<String, dynamic>> updateSavedBuild(String id, String name) async {
    final res = await api.put('/builder/update/$id', {'name': name});
    return res;
  }
}
