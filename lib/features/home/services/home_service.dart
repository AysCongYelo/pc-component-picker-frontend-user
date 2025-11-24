import 'package:dio/dio.dart';
import 'package:frontend/core/constants/env.dart';

class HomeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  Future<List<dynamic>> getFeatured() async {
    final res = await _dio.get('/featuredbuildspublic/featured');
    return res.data['data'];
  }

  Future<List<dynamic>> getTrending() async {
    final res = await _dio.get('/componentspublic/trending');
    return res.data['data'];
  }
}
