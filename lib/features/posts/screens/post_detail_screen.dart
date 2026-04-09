import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/posts_provider.dart';

final postDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final service = ref.read(postsServiceProvider);
  return service.getPost(slug);
});

class PostDetailScreen extends ConsumerWidget {
  final String slug;

  const PostDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(slug));

    return Scaffold(
      appBar: AppBar(title: const Text('Recept')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Greška: $e')),
        data: (post) {
          final imageUrl = post['image'] != null
              ? 'http://kulinar.test/storage/${post['image']}'
              : null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? '',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (post['user']?['avatar'] != null)
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(post['user']['avatar']),
                            )
                          else
                            CircleAvatar(
                              radius: 16,
                              child: Text(
                                (post['user']?['name'] ?? 'U')[0].toUpperCase(),
                              ),
                            ),
                          const SizedBox(width: 10),
                          Text(post['user']?['name'] ?? ''),
                        ],
                      ),
                      if (post['excerpt'] != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          post['excerpt'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const Divider(height: 32),
                      Html(data: post['content'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
