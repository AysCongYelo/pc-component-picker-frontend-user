import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/core/services/api_client_provider.dart';
import '../services/home_service.dart';

/// Provide HomeService once only (singleton)
final homeServiceProvider = Provider<HomeService>((ref) {
  final api = ref.read(apiClientProvider);
  return HomeService(api);
});

/// Featured Builds Provider
final homeFeaturedProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(homeServiceProvider);

  try {
    final result = await service.getFeatured();
    return result;
  } catch (e, st) {
    // print("Home Featured Error: $e\n$st");
    return [];
  }
});

/// Trending Components Provider
final homeTrendingProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(homeServiceProvider);

  try {
    final result = await service.getTrending();
    return result;
  } catch (_) {
    return [];
  }
});
