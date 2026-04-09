import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/posts_provider.dart';
import '../../auth/providers/auth_provider.dart';

final myPostsCountProvider = FutureProvider<int>((ref) async {
  final isLoggedIn = ref.watch(authProvider).isLoggedIn;
  if (!isLoggedIn) return 0;
  final service = ref.read(postsServiceProvider);
  final result = await service.myPosts(page: 1);
  return result['total'] as int? ?? 0;
});

const kOrange = Color(0xFFE85D04);
const kBg = Color(0xFF181818);
const kSurface = Color(0xFF242424);
const kCard = Color(0xFF2C2C2C);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postsProvider.notifier).loadPosts(refresh: true));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(postsProvider.notifier).loadPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final authState = ref.watch(authProvider);
    final myPostsCount = ref.watch(myPostsCountProvider);
    final userName = authState.user?['name']?.split(' ').first ?? 'Majstore';

    return Scaffold(
      body: RefreshIndicator(
        color: kOrange,
        backgroundColor: kSurface,
        onRefresh: () async => ref.read(postsProvider.notifier).loadPosts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // AppBar
            SliverAppBar(
              floating: true,
              backgroundColor: kBg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 0,
              titleSpacing: 20,
              title: Row(
                children: [
                  kIsWeb
                      ? Image.network('/logo.png', height: 36,
                          errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: kOrange, size: 32))
                      : Image.asset('assets/images/logo.png', height: 36,
                          errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: kOrange, size: 32)),
                  const SizedBox(width: 10),
                  const Text(
                    'KULINAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: kOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('2', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (authState.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _showProfileMenu(context, ref),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: kOrange.withOpacity(0.2),
                        backgroundImage: authState.user?['avatar'] != null
                            ? NetworkImage(authState.user!['avatar'])
                            : null,
                        child: authState.user?['avatar'] == null
                            ? Text(
                                (authState.user?['name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Prijava', style: TextStyle(color: kOrange)),
                  ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pozdrav
                    Text(
                      'Dobrodošao natrag,',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userName! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vrijeme je za nešto fino.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // Stats kartice
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.restaurant_menu,
                            value: myPostsCount.when(data: (c) => '$c', loading: () => '...', error: (_, __) => '0'),
                            label: 'Moji recepti',
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            value: '5',
                            label: 'Dovršeni ovaj tjedan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Brzi pristup
                    const Text(
                      'Brzi pristup',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickButton(
                            icon: Icons.menu_book_outlined,
                            label: 'Svi recepti',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickButton(
                            icon: Icons.calculate_outlined,
                            label: 'Kalkulator',
                            onTap: () => context.go('/kalkulatori'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickButton(
                            icon: Icons.settings_outlined,
                            label: 'Postavke',
                            onTap: () => context.push(authState.isLoggedIn ? '/postavke' : '/login'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Nedavni recepti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nedavni recepti',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Pogledaj sve',
                            style: TextStyle(color: kOrange, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Lista recepata
            postsState.posts.isEmpty && postsState.isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: kOrange)),
                  )
                : postsState.posts.isEmpty
                    ? SliverFillRemaining(
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
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                ),
                                child: const Text('Dodaj recept'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == postsState.posts.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(color: kOrange),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: _PostListTile(post: postsState.posts[index]),
                            );
                          },
                          childCount: postsState.posts.length + (postsState.hasMore ? 1 : 0),
                        ),
                      ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: kOrange),
            title: const Text('Moji recepti', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(context); context.push('/my-posts'); },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: const Text('Odjava', style: TextStyle(color: Colors.white54)),
            onTap: () { Navigator.pop(context); ref.read(authProvider.notifier).logout(); },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kOrange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kOrange.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: kOrange, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostListTile extends StatelessWidget {
  final Map<String, dynamic> post;

  const _PostListTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['image'] != null
        ? 'https://kulinar.app/storage/${post['image']}'
        : null;

    return GestureDetector(
      onTap: () => context.push('/posts/${post['slug']}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(width: 64, height: 64, color: Colors.white10),
                      errorWidget: (_, __, ___) => _PlaceholderThumb(),
                    )
                  : _PlaceholderThumb(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post['user']?['name'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: kOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.restaurant, color: kOrange, size: 28),
    );
  }
}
