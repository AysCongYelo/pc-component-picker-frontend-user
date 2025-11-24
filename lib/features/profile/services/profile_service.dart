import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/env.dart';

class ProfileService {
  late Dio _dio;

  ProfileService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // GET /api/profile
  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _dio.get('/profile');
    return res.data['profile']; // FIX
  }

  // PUT /api/profile
  Future<bool> updateProfile(String fullName) async {
    final res = await _dio.put(
      '/profile',
      data: {'full_name': fullName}, // FIX
    );

    return res.data['success'] == true;
  }

  // POST /api/profile/avatar
  Future<bool> updateAvatar(File file) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final res = await _dio.post(
      '/profile/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return res.data['success'] == true;
  }
}
