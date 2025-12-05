import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/core/services/api_client.dart';

final savedBuildsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final api = ApiClient.create();

      final res = await api.get("/builder/my");

      if (res is Map && res["builds"] is List) {
        return (res["builds"] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      throw Exception("Invalid response format: expected { builds: [] }");
    });
