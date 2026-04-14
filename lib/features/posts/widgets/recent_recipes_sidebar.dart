import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/landing/stats_provider.dart';

const _kOrange = Color(0xFFE85D04);
const _kCard = Color(0xFF2C2C2C);
const _kSurface = Color(0xFF242424);

class RecentRecipesSidebar extends ConsumerWidget {
  const RecentRecipesSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(landingPostsProvider);

    return Container(
      width: 260,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 12),
            child: Text(
              'Zadnji recepti',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          postsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (posts) => Column(
              children: posts
                  .take(6)
                  .map((post) => _SidebarRecipeCard(post: post))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarRecipeCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _SidebarRecipeCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final slug = post['slug'] as String? ?? '';
    final title = post['title'] as String? ?? '';
    final image = post['image'] as String?;
    final avgRating = (post['rating_average'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = (post['rating_count'] as num?)?.toInt() ?? 0;

    String? imageUrl;
    if (image != null && image.isNotEmpty) {
      imageUrl = image.startsWith('http') ? image : 'https://kulinar.app/storage/$image';
    }

    return GestureDetector(
      onTap: () => context.push('/posts/$slug'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                        placeholder: (_, __) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    if (ratingCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: _kOrange, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: _kOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($ratingCount)',
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: _kSurface,
        child: const Center(
          child: Icon(Icons.restaurant, color: Colors.white24, size: 22),
        ),
      );
}
