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
  int? _myRating;
  double? _avgRating;
  int? _ratingCount;
  bool _ratingLoading = false;

  Future<void> _rate(int postId, int rating) async {
    if (_ratingLoading) return;
    setState(() => _ratingLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.dio.post('/posts/$postId/rate', data: {'rating': rating});
      setState(() {
        _myRating = rating;
        _avgRating = (resp.data['average'] as num).toDouble();
        _ratingCount = resp.data['count'] as int;
      });
    } catch (_) {} finally {
      setState(() => _ratingLoading = false);
    }
  }

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
          final currentUserId = authState.user?['id'];
          final postUserId = post['user']?['id'] ?? post['user_id'];
          final isOwner = currentUserId != null && currentUserId == postUserId;
          final isBookmarked = _isBookmarked ?? (post['is_bookmarked'] == true);
          final postId = (post['id'] as num).toInt();
          final avgRating = _avgRating ?? (post['rating_average'] as num?)?.toDouble() ?? 0.0;
          final ratingCount = _ratingCount ?? post['rating_count'] as int? ?? 0;
          final myRating = _myRating ?? post['my_rating'] as int?;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: imageUrl != null ? 260 : 0,
                pinned: true,
                backgroundColor: kBg,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: kOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                actions: [
                  if (authState.isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _bookmarkLoading
                          ? Container(
                              width: 36, height: 36,
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(color: kOrange, strokeWidth: 2),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _toggleBookmark(postId),
                              child: Container(
                                width: 36, height: 36,
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: isBookmarked ? kOrange : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                    ),
                  if (isOwner) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: GestureDetector(
                        onTap: () => context.push('/posts/${widget.slug}/edit'),
                        child: Container(
                          width: 36, height: 36,
                          decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 19),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _deletePost(postId),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post['title'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => context.push('/posts/${widget.slug}/edit'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: kOrange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                                    SizedBox(width: 5),
                                    Text('Uredi', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
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
                      const SizedBox(height: 16),
                      // Rating widget
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ..._buildStars(avgRating, 20),
                                const SizedBox(width: 8),
                                if (avgRating > 0)
                                  Text('$avgRating',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                if (ratingCount > 0) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.person_outline, color: Colors.white38, size: 15),
                                  const SizedBox(width: 2),
                                  Text('$ratingCount',
                                      style: const TextStyle(color: Colors.white38, fontSize: 13)),
                                ],
                                if (avgRating == 0)
                                  const Text('Nema ocjena još',
                                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                              ],
                            ),
                            if (authState.isLoggedIn && !isOwner) ...[
                              const SizedBox(height: 12),
                              Text(
                                myRating != null ? 'Tvoja ocjena:' : 'Ocijeni recept:',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (i) {
                                  final star = i + 1;
                                  return GestureDetector(
                                    onTap: _ratingLoading ? null : () => _rate(postId, star),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        star <= (myRating ?? 0) ? Icons.star : Icons.star_border,
                                        color: star <= (myRating ?? 0) ? kOrange : Colors.white38,
                                        size: 36,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildContentArea(context, post),
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

  Widget _buildContentArea(BuildContext context, Map<String, dynamic> post) {
    final isDesktop = MediaQuery.of(context).size.width > 960;
    final hasIngredients = _hasIngredients(post);

    final excerptWidget = post['excerpt'] != null
        ? Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kOrange.withOpacity(0.2)),
            ),
            child: Text(
              post['excerpt'],
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.7),
            ),
          )
        : null;

    final htmlWidget = Html(
      data: _prepareContent(post['content'] ?? ''),
      style: {
        'body': Style(color: Colors.white, fontSize: FontSize(16), lineHeight: LineHeight(1.8)),
        'p': Style(color: Colors.white, fontSize: FontSize(16), lineHeight: LineHeight(1.8), margin: Margins.only(bottom: 12)),
        'h1': Style(color: Colors.white, fontWeight: FontWeight.w800, fontSize: FontSize(22), margin: Margins.only(top: 20, bottom: 8)),
        'h2': Style(color: kOrange, fontWeight: FontWeight.w700, fontSize: FontSize(18), margin: Margins.only(top: 18, bottom: 6)),
        'h3': Style(color: Colors.white, fontWeight: FontWeight.w600, fontSize: FontSize(16), margin: Margins.only(top: 14, bottom: 4)),
        'strong': Style(color: Colors.white, fontWeight: FontWeight.w700),
        'em': Style(color: Colors.white70, fontStyle: FontStyle.italic),
        'li': Style(color: Colors.white, fontSize: FontSize(16), lineHeight: LineHeight(1.8), margin: Margins.only(bottom: 4)),
        'ul': Style(margin: Margins.only(bottom: 12, left: 8)),
        'ol': Style(margin: Margins.only(bottom: 12, left: 8)),
      },
    );

    if (isDesktop && hasIngredients) {
      // Desktop: tekst lijevo, namirnice desno
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lijevo — content
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (excerptWidget != null) ...[excerptWidget, const SizedBox(height: 16)],
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                htmlWidget,
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Desno — namirnice
          Expanded(
            flex: 2,
            child: _buildIngredientsCard(post),
          ),
        ],
      );
    }

    // Mobile / nema namirnica — stacked
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (excerptWidget != null) ...[excerptWidget, const SizedBox(height: 16)],
        if (hasIngredients) ...[_buildIngredientsCard(post), const SizedBox(height: 20)],
        const Divider(color: Colors.white12),
        const SizedBox(height: 8),
        htmlWidget,
      ],
    );
  }

  bool _hasIngredients(Map<String, dynamic> post) {
    final servings = post['servings'];
    final ingredients = post['ingredients'];
    return (servings != null && (servings as num) > 0) ||
        (ingredients is List && ingredients.isNotEmpty);
  }

  Widget _buildIngredientsCard(Map<String, dynamic> post) {
    final servings = post['servings'] as num?;
    final rawIngredients = post['ingredients'];
    final List<dynamic> ingredients =
        rawIngredients is List ? rawIngredients : [];

    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, color: kOrange, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Namirnice',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                if (servings != null && servings > 0) ...[
                  const Spacer(),
                  const Icon(Icons.people_outline,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'Za $servings ${_servingsLabel(servings.toInt())}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          if (ingredients.isNotEmpty) ...[
            const Divider(height: 1, color: Colors.white10),
            // Column headers
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: const [
                  Expanded(
                    flex: 5,
                    child: Text('Namirnica',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Količina',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Jedinica',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            ...List.generate(ingredients.length, (i) {
              final ing = ingredients[i] as Map<String, dynamic>? ?? {};
              final isLast = i == ingredients.length - 1;
              return Column(
                children: [
                  const Divider(height: 1, color: Colors.white10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: kOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ing['name']?.toString() ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            ing['quantity']?.toString() ?? '',
                            style: const TextStyle(
                                color: kOrange, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            ing['unit']?.toString() ?? '',
                            style: const TextStyle(
                                color: kOrange, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _prepareContent(String content) {
    // If already contains HTML tags, return as-is
    if (content.contains('<') && content.contains('>')) return content;
    // Plain text: wrap paragraphs in <p> tags
    final paragraphs = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (paragraphs.isEmpty) return content;
    return paragraphs.map((p) => '<p>${p.trim()}</p>').join('');
  }

  String _servingsLabel(int n) {
    if (n == 1) return 'osobu';
    if (n >= 2 && n <= 4) return 'osobe';
    return 'osoba';
  }

  List<Widget> _buildStars(double avg, double size) {
    return List.generate(5, (i) {
      IconData icon;
      if (avg >= i + 1) {
        icon = Icons.star;
      } else if (avg >= i + 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, color: avg > 0 ? kOrange : Colors.white24, size: size);
    });
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
