import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/posts_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';

const _kOrange = Color(0xFFE85D04);
const _kBg = Color(0xFF181818);
const _kCard = Color(0xFF2C2C2C);
const _kSurface = Color(0xFF242424);

class ReceptiScreen extends ConsumerStatefulWidget {
  const ReceptiScreen({super.key});

  @override
  ConsumerState<ReceptiScreen> createState() => _ReceptiScreenState();
}

class _ReceptiScreenState extends ConsumerState<ReceptiScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _myPostsOnly = false;
  bool _bookmarksOnly = false;
  String _lastSearch = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postsProvider.notifier).loadPosts(refresh: true));
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postsProvider.notifier).loadPosts();
    }
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q == _lastSearch) return;
    _lastSearch = q;
    ref.read(postsProvider.notifier).setSearch(q);
  }

  void _toggleMyPosts(bool value) {
    setState(() {
      _myPostsOnly = value;
      if (value) _bookmarksOnly = false;
    });
    ref.read(postsProvider.notifier).setMyPostsOnly(value);
  }

  void _toggleBookmarks(bool value) {
    setState(() {
      _bookmarksOnly = value;
      if (value) _myPostsOnly = false;
    });
    ref.read(postsProvider.notifier).setBookmarksOnly(value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;

    return Scaffold(
      backgroundColor: _kBg,
      body: RefreshIndicator(
        color: _kOrange,
        backgroundColor: _kSurface,
        onRefresh: () async =>
            ref.read(postsProvider.notifier).loadPosts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: _kBg,
              surfaceTintColor: Colors.transparent,
              titleSpacing: 20,
              title: const Text(
                'Recepti',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: _kOrange, size: 28),
                  onPressed: () => context.push('/posts/create'),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isLoggedIn ? 100 : 60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      // Search bar + filter pills u jednom redu
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Pretraži recepte...',
                                hintStyle: const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                                        onPressed: () => _searchController.clear(),
                                      )
                                    : null,
                                filled: true,
                                fillColor: const Color(0xFF2C2C2C),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(width: 8),
                            // Moji recepti pill
                            _FilterPill(
                              active: _myPostsOnly,
                              icon: _myPostsOnly ? Icons.person : Icons.person_outline,
                              onTap: () => _toggleMyPosts(!_myPostsOnly),
                            ),
                            const SizedBox(width: 6),
                            // Favoriti pill
                            _FilterPill(
                              active: _bookmarksOnly,
                              icon: _bookmarksOnly ? Icons.bookmark : Icons.bookmark_border,
                              onTap: () => _toggleBookmarks(!_bookmarksOnly),
                            ),
                          ],
                        ],
                      ),
                      if (isLoggedIn && (_myPostsOnly || _bookmarksOnly)) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _myPostsOnly ? 'Prikazuju se samo tvoji recepti' : 'Prikazuju se samo spremljeni recepti',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (postsState.posts.isEmpty && postsState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: _kOrange)),
              )
            else if (postsState.posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('Nema recepata. Budi prvi!',
                          style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/posts/create'),
                        child: const Text('Dodaj recept'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == postsState.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2)),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecipeCard(
                          post: postsState.posts[index],
                          currentUserId: authState.user?['id'],
                        ),
                      );
                    },
                    childCount: postsState.posts.length + (postsState.hasMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final dynamic currentUserId;

  const _RecipeCard({required this.post, this.currentUserId});

  @override
  ConsumerState<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends ConsumerState<_RecipeCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _deleting = false;
  int? _myRating;
  double? _avgRating;
  int? _ratingCount;
  bool _ratingLoading = false;
  late AnimationController _animController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  Future<void> _delete(BuildContext context) async {
    final slug = widget.post['slug'] as String? ?? '';
    final id = widget.post['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kSurface,
        title: const Text('Obriši recept', style: TextStyle(color: Colors.white)),
        content: const Text('Jesi li siguran? Ova akcija se ne može poništiti.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() => _deleting = true);

    try {
      final service = ref.read(postsServiceProvider);
      await service.deletePost(id);
      ref.read(postsProvider.notifier).loadPosts(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
        );
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final imageUrl = post['image'] != null
        ? 'https://kulinar.app/storage/${post['image']}'
        : null;
    final title = post['title'] as String? ?? '';
    final excerpt = post['excerpt'] as String? ?? '';
    final content = post['content'] as String? ?? '';
    final authorName = post['user']?['name'] as String? ?? '';
    final authorAvatar = post['user']?['avatar'] as String?;
    final slug = post['slug'] as String? ?? '';
    final postUserId = post['user']?['id'] ?? post['user_id'];
    final isOwner = widget.currentUserId != null &&
        widget.currentUserId.toString() == postUserId.toString();
    final postId = (post['id'] as num?)?.toInt() ?? 0;
    final avgRating = _avgRating ?? (post['rating_average'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = _ratingCount ?? (post['rating_count'] as num?)?.toInt() ?? 0;
    final myRating = _myRating ?? post['my_rating'] as int?;
    final isLoggedIn = widget.currentUserId != null;

    if (_deleting) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: _kCard.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded ? _kOrange.withOpacity(0.4) : Colors.white10,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Glavna kartica
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Slika
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _thumb(),
                            errorWidget: (_, __, ___) => _thumb(),
                          )
                        : _thumb(),
                  ),
                  const SizedBox(width: 14),
                  // Tekst
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Rating stars below title
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < avgRating.round() ? Icons.star : Icons.star_border,
                              color: avgRating > 0 ? _kOrange : Colors.white24,
                              size: 13,
                            )),
                            if (avgRating > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '$avgRating${ratingCount > 0 ? ' ($ratingCount)' : ''}',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                        if (excerpt.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            excerpt,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (authorAvatar != null)
                              CircleAvatar(
                                radius: 9,
                                backgroundImage: NetworkImage(authorAvatar),
                                backgroundColor: _kOrange.withOpacity(0.2),
                              )
                            else
                              CircleAvatar(
                                radius: 9,
                                backgroundColor: _kOrange.withOpacity(0.2),
                                child: Text(
                                  authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      color: _kOrange, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Text(authorName,
                                style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            if (isOwner) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('tvoj',
                                    style: TextStyle(color: _kOrange, fontSize: 9)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Više dugme
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _expanded
                            ? _kOrange.withOpacity(0.15)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: _expanded ? _kOrange : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable sadržaj
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                Divider(
                    color: _kOrange.withOpacity(0.2),
                    height: 1,
                    indent: 14,
                    endIndent: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content.isNotEmpty) ...[
                        Text(
                          content,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13, height: 1.6),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                      ],
                      // Interactive rating (logged in, not owner)
                      if (isLoggedIn && !isOwner && postId > 0) ...[
                        Row(
                          children: [
                            Text(
                              myRating != null ? 'Tvoja ocjena:' : 'Ocijeni:',
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(5, (i) {
                              final star = i + 1;
                              return GestureDetector(
                                onTap: _ratingLoading ? null : () => _rate(postId, star),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    star <= (myRating ?? 0) ? Icons.star : Icons.star_border,
                                    color: star <= (myRating ?? 0) ? _kOrange : Colors.white24,
                                    size: 24,
                                  ),
                                ),
                              );
                            }),
                            if (_ratingLoading) ...[
                              const SizedBox(width: 6),
                              const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(color: _kOrange, strokeWidth: 1.5),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      // Akcijski gumbi
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/posts/$slug'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.open_in_full, size: 15, color: Colors.white),
                              label: const Text('Cijeli recept',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => context.push('/posts/$slug/edit'),
                              icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                              tooltip: 'Uredi',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.06),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => _delete(context),
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              tooltip: 'Obriši',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.08),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _kOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.restaurant, color: _kOrange, size: 30),
      );
}

class _FilterPill extends StatelessWidget {
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterPill({required this.active, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? _kOrange : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _kOrange : Colors.white24),
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white54, size: 20),
      ),
    );
  }
}
