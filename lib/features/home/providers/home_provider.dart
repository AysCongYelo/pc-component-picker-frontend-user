import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/home_service.dart';

final homeFeaturedProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = HomeService();
  return await service.getFeatured();
});

final homeTrendingProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = HomeService();
  return await service.getTrending();
});
