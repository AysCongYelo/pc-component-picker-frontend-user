import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/core/services/api_client_provider.dart';
import '../services/featured_service.dart';

// Service provider (DI)
final featuredServiceProvider = Provider<FeaturedService>((ref) {
  final api = ref.read(apiClientProvider);
  return FeaturedService(api);
});

// FutureProvider to fetch featured builds
final featuredBuildsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(featuredServiceProvider);

  try {
    final builds = await service.getFeaturedBuilds();
    return builds;
  } catch (e, st) {
    // Optional logging
    // print("Featured error: $e");
    throw e;
    ; // Safe fallback
  }
});
