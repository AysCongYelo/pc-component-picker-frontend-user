import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/trending_service.dart';

final trendingComponentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = TrendingService();
  return await service.getTrendingComponents();
});
