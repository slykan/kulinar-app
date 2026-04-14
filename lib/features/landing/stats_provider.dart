import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

final landingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  try {
    final response = await client.dio.get(
      '/stats',
      options: Options(sendTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8)),
    );
    return response.data as Map<String, dynamic>;
  } catch (_) {
    return {'user_count': 0, 'post_count': 0, 'recent_users': [], 'recent_posts': []};
  }
});

final landingPostsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  try {
    final response = await client.dio.get(
      '/posts',
      queryParameters: {'page': 1, 'per_page': 9},
      options: Options(sendTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8)),
    );
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List).cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});
