import 'package:frontend/core/services/api_client.dart';

class HomeService {
  final ApiClient api;

  HomeService(this.api);

  Future<List<dynamic>> getFeatured() async {
    final res = await api.get('/featuredbuilds');

    if (res is Map && res['data'] != null) {
      return res['data'] as List<dynamic>;
    }

    return [];
  }

  Future<List<dynamic>> getTrending() async {
    final res = await api.get('/componentspublic/trending');

    if (res is Map && res['data'] != null) {
      return res['data'] as List<dynamic>;
    }

    return [];
  }
}
