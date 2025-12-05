import 'package:pc_component_picker/core/services/api_client.dart';

class TrendingService {
  final ApiClient api;

  TrendingService(this.api);

  Future<List<dynamic>> getTrendingComponents() async {
    final res = await api.get('/componentspublic/trending');

    if (res is Map && res['data'] != null) {
      return res['data'] as List<dynamic>;
    }

    return [];
  }
}
