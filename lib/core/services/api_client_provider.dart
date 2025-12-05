import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/core/services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create();
});
