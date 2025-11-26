import 'package:frontend/core/services/api_client.dart';

class FeaturedService {
  final ApiClient api;

  FeaturedService(this.api);

  Future<List<dynamic>> getFeaturedBuilds() async {
    final res = await api.get('/featuredbuildspublic');

    if (res is Map && res['data'] != null) {
      return res['data'] as List<dynamic>;
    }

    return [];
  }
}
