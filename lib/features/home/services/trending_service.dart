import 'package:dio/dio.dart';
import 'package:frontend/core/constants/env.dart';

class TrendingService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  Future<List<dynamic>> getTrendingComponents() async {
    final res = await _dio.get('/componentspublic/trending');
    return res.data['data'] ?? [];
  }
}
