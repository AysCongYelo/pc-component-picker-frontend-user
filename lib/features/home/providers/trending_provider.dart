import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/api_client_provider.dart';
import '../services/trending_service.dart';

/// Create one instance only
final trendingServiceProvider = Provider<TrendingService>((ref) {
  final api = ref.read(apiClientProvider);
  return TrendingService(api);
});

/// Trending components provider
final trendingComponentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(trendingServiceProvider);

  try {
    final list = await service.getTrendingComponents();
    return list;
  } catch (e, st) {
    // print("Trending error: $e");
    return []; // prevent crash
  }
});
