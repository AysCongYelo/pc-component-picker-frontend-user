import 'package:dio/dio.dart';
import 'package:frontend/core/constants/env.dart';

class FeaturedService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  Future<List<dynamic>> getFeaturedBuilds() async {
    final res = await _dio.get('/featuredbuildspublic/featured');
    return res.data['data'] ?? [];
  }
}
