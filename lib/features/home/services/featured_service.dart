import 'package:pc_component_picker/core/services/api_client.dart';

class FeaturedService {
  final ApiClient api;

  FeaturedService(this.api);

  /// GET ALL FEATURED BUILDS
  Future<List<dynamic>> getFeaturedBuilds() async {
    final res = await api.get('/featuredbuildspublic');

    if (res is Map && res['data'] != null) {
      return res['data'] as List<dynamic>;
    }

    return [];
  }

  /// GET SINGLE FEATURED BUILD WITH ITEMS
  Future<Map<String, dynamic>?> getFeaturedBuild(String id) async {
    final res = await api.get('/featuredbuildspublic/$id');

    if (res is Map && res['data'] != null) {
      return res['data'] as Map<String, dynamic>;
    }

    return null;
  }
}
