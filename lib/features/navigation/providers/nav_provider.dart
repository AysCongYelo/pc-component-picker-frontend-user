import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls bottom navigation index across the app.
final navIndexProvider = StateProvider<int>((ref) => 0);
