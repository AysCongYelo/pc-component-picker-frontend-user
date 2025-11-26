import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create();
});
