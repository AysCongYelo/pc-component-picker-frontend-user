import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/api_client.dart';

final savedBuildsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final api = ApiClient.create();

      // /builder/my returns a LIST, not an object
      final res = await api.get("/builder/my");

      if (res is List) {
        return res.map((e) => e as Map<String, dynamic>).toList();
      }

      throw Exception("Invalid response format: expected List");
    });
