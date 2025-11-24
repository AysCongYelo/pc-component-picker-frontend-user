import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/featured_service.dart';

final featuredBuildsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = FeaturedService();
  return await service.getFeaturedBuilds();
});
