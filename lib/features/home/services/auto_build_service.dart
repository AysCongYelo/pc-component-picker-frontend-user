import 'package:frontend/core/services/api_client.dart';

class AutoBuildService {
  final ApiClient api;

  AutoBuildService(this.api);

  Future<Map<String, dynamic>> autoBuild({
    required String purpose,
    required double budget,
  }) async {
    return await api.post("/builder/autobuild", {
      "purpose": purpose,
      "budget": budget,
    });
  }
}
