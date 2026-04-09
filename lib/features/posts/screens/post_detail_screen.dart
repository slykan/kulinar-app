import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/posts_provider.dart';
import '../../auth/providers/auth_provider.dart';

const kOrange = Color(0xFFE85D04);
const kBg = Color(0xFF181818);
const kCard = Color(0xFF242424);

final postDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final service = ref.read(postsServiceProvider);
  return service.getPost(slug);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const PostDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool? _isBookmarked;
  bool _bookmarkLoading = false;

  Future<void> _toggleBookmark(int postId) async {
    setState(() => _bookmarkLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.dio.post('/posts/$postId/bookmark');
      setState(() => _isBookmarked = response.data['bookmarked'] as bool);
    } catch (_) {} finally {
      setState(() => _bookmarkLoading = false);
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Obriši recept', style: TextStyle(color: Colors.white)),
        content: const Text('Jesi li siguran? Recept će biti trajno obrisan.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Odustani', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Obriši', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final service = ref.read(postsServiceProvider);
      await service.deletePost(postId);
      ref.read(postsProvider.notifier).refresh();
      if (mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recept obrisan.'), backgroundColor: kOrange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.slug));
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: kBg,
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kOrange)),
        error: (e, _) => Center(child: Text('Greška: $e', style: const TextStyle(color: Colors.white))),
        data: (post) {
          final imageUrl = post['image'] != null
              ? 'https://kulinar.app/storage/${post['image']}'
              : null;
          final isOwner = post['is_owner'] == true;
          final isBookmarked = _isBookmarked ?? (post['is_bookmarked'] == true);
          final postId = post['id'] as int;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: imageUrl != null ? 260 : 0,
                pinned: true,
                backgroundColor: kBg,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  if (authState.isLoggedIn)
                    _bookmarkLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: kOrange, strokeWidth: 2)),
                          )
                        : IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? kOrange : Colors.white,
                            ),
                            onPressed: () => _toggleBookmark(postId),
                          ),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deletePost(postId),
                    ),
                ],
                flexibleSpace: imageUrl != null
                    ? FlexibleSpaceBar(
                        background: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: kOrange.withOpacity(0.2),
                            backgroundImage: post['user']?['avatar'] != null
                                ? NetworkImage(post['user']['avatar'])
                                : null,
                            child: post['user']?['avatar'] == null
                                ? Text((post['user']?['name'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold))
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['user']?['name'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(post['created_at'] != null
                                  ? _formatDate(post['created_at'])
                                  : '',
                                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      if (post['excerpt'] != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kOrange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kOrange.withOpacity(0.2)),
                          ),
                          child: Text(
                            post['excerpt'],
                            style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 8),
                      Html(
                        data: post['content'] ?? '',
                        style: {
                          'body': Style(color: Colors.white70, fontSize: FontSize(15), lineHeight: LineHeight(1.6)),
                          'h1': Style(color: Colors.white, fontWeight: FontWeight.bold),
                          'h2': Style(color: Colors.white, fontWeight: FontWeight.bold),
                          'h3': Style(color: Colors.white, fontWeight: FontWeight.w600),
                          'strong': Style(color: Colors.white),
                          'p': Style(color: Colors.white70),
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}.${dt.month}.${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
