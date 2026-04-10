import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/api/api_client.dart';
import 'stats_provider.dart';

const kOrange = Color(0xFFE85D04);
const kBg = Color(0xFF181818);
const kCard = Color(0xFF242424);

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Navbar(isLoggedIn: auth.isLoggedIn, user: auth.user),
            _Hero(isLoggedIn: auth.isLoggedIn, user: auth.user),
            _Features(),
            _RecentPosts(),
            _Stats(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Navbar extends ConsumerWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? user;

  const _Navbar({required this.isLoggedIn, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: kBg.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          kIsWeb
              ? Image.network('/logo.png', height: 56, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: kOrange, size: 56))
              : Image.asset('assets/images/logo.png', height: 56, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: kOrange, size: 56)),
          const Spacer(),
          if (MediaQuery.of(context).size.width > 700 && !isLoggedIn) ...[
            _NavLink(label: 'Registracija', onTap: () => context.go('/register')),
            const SizedBox(width: 16),
          ],
          if (isLoggedIn)
            Row(
              children: [
                if (user?['avatar'] != null)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(user!['avatar']),
                    backgroundColor: kOrange.withOpacity(0.3),
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: kOrange.withOpacity(0.3),
                    child: Text(
                      (user?['name'] as String? ?? 'K')[0].toUpperCase(),
                      style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Odjava', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Prijava', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? user;

  const _Hero({required this.isLoggedIn, this.user});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
        ),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _HeroContent(isLoggedIn: isLoggedIn, user: user)),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: _HeroVisual(isLoggedIn: isLoggedIn, user: user)),
              ],
            )
          : Column(
              children: [
                _HeroContent(isLoggedIn: isLoggedIn, user: user),
                const SizedBox(height: 40),
                _HeroVisual(isLoggedIn: isLoggedIn, user: user),
              ],
            ),
    );
  }
}

class _HeroContent extends ConsumerWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? user;

  const _HeroContent({required this.isLoggedIn, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?['name'] as String? ?? '';
    final firstName = name.split(' ').first;
    final statsAsync = ref.watch(landingStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: kIsWeb
              ? Image.network('/logo.png', height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: kOrange, size: 100))
              : Image.asset('assets/images/logo.png', height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: kOrange, size: 100)),
        ),
        const SizedBox(height: 32),
        if (isLoggedIn) ...[
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.1),
              children: [
                TextSpan(text: 'Dobrodošao, ', style: const TextStyle(color: Colors.white)),
                TextSpan(text: '$firstName!', style: const TextStyle(color: kOrange)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tvoja kuhinja te čeka.\nPregledaj recepte, izradi nove\ni dijeli svoju strast prema hrani.',
            style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Builder(builder: (context) => ElevatedButton.icon(
                onPressed: () => context.go('/posts/create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novi recept', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              )),
              Builder(builder: (context) => OutlinedButton.icon(
                onPressed: () => context.push('/profil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('Moj profil', style: TextStyle(fontSize: 15)),
              )),
            ],
          ),
        ] else ...[
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.1),
              children: [
                TextSpan(text: 'Recepti. Preciznost. ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Strast.', style: TextStyle(color: kOrange)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'KULINAR je tvoja kuhinja u džepu.\nSpremi recepte, izračunaj količine do savršenstva\ni kuhaj s više strasti nego ikad.',
            style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Builder(builder: (context) => ElevatedButton.icon(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Počni odmah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              )),
              Builder(builder: (context) => OutlinedButton.icon(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Prijava', style: TextStyle(fontSize: 15)),
              )),
            ],
          ),
          const SizedBox(height: 32),
          statsAsync.when(
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox(height: 48),
            data: (stats) {
              final recentUsers = (stats['recent_users'] as List<dynamic>?) ?? [];
              final userCount = stats['user_count'] as int? ?? 0;
              final countLabel = userCount >= 1000
                  ? '${(userCount / 1000).toStringAsFixed(userCount % 1000 == 0 ? 0 : 1)}k+'
                  : '$userCount+';
              return Row(
                children: [
                  SizedBox(
                    width: recentUsers.isEmpty ? 0 : (recentUsers.length * 22.0 + 10),
                    height: 36,
                    child: Stack(
                      children: List.generate(recentUsers.length, (i) {
                        final u = recentUsers[i] as Map<String, dynamic>;
                        final avatar = u['avatar'] as String?;
                        final initials = (u['initials'] as String?) ?? '?';
                        return Positioned(
                          left: i * 22.0,
                          child: avatar != null && avatar.isNotEmpty
                              ? CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(avatar),
                                  backgroundColor: kOrange.withOpacity(0.3),
                                )
                              : CircleAvatar(
                                  radius: 16,
                                  backgroundColor: kOrange.withOpacity(0.3),
                                  child: Text(initials, style: const TextStyle(color: kOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: List.generate(5, (_) => const Icon(Icons.star, color: kOrange, size: 14))),
                      const SizedBox(height: 2),
                      Text('Pridružilo se $countLabel kuhara', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _HeroVisual extends ConsumerWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? user;

  const _HeroVisual({required this.isLoggedIn, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?['name'] as String? ?? 'Majstore';
    final firstName = name.split(' ').first;
    final statsAsync = ref.watch(landingStatsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kOrange.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: kOrange.withOpacity(0.1), blurRadius: 40, spreadRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLoggedIn ? 'Dobrodošao natrag,' : 'Pozdrav, gost!',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            isLoggedIn ? '$firstName! 👋' : 'Pridruži nam se 👋',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            isLoggedIn ? 'Vrijeme je za nešto fino.' : 'Kuhinja čeka.',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            loading: () => Row(children: [
              Expanded(child: _MiniStatCard(icon: Icons.restaurant_menu, value: '…', label: 'Recepata')),
              const SizedBox(width: 12),
              Expanded(child: _MiniStatCard(icon: Icons.people_outline, value: '…', label: 'Kuhara')),
            ]),
            error: (_, __) => Row(children: [
              Expanded(child: _MiniStatCard(icon: Icons.restaurant_menu, value: '—', label: 'Recepata')),
              const SizedBox(width: 12),
              Expanded(child: _MiniStatCard(icon: Icons.people_outline, value: '—', label: 'Kuhara')),
            ]),
            data: (stats) {
              final userCount = stats['user_count'] as int? ?? 0;
              final postCount = stats['post_count'] as int? ?? 0;
              String fmt(int n) => n >= 1000
                  ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k+'
                  : '$n+';
              return Row(children: [
                Expanded(child: _MiniStatCard(icon: Icons.restaurant_menu, value: fmt(postCount), label: 'Recepata')),
                const SizedBox(width: 12),
                Expanded(child: _MiniStatCard(icon: Icons.people_outline, value: fmt(userCount), label: 'Kuhara')),
              ]);
            },
          ),
          const SizedBox(height: 16),
          const Text('Popularni recepti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          statsAsync.when(
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox(height: 80),
            data: (stats) {
              final posts = (stats['recent_posts'] as List<dynamic>?) ?? [];
              if (posts.isEmpty) return const Text('Nema recepata još.', style: TextStyle(color: Colors.white38, fontSize: 12));
              return Column(
                children: posts.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value as Map<String, dynamic>;
                  final title = p['title'] as String? ?? '';
                  final excerpt = p['excerpt'] as String? ?? '';
                  final image = p['image'] as String?;
                  final slug = p['slug'] as String?;
                  return Padding(
                    padding: EdgeInsets.only(top: i > 0 ? 8.0 : 0),
                    child: _MiniPostTile(
                      title: title,
                      sub: excerpt.isNotEmpty ? excerpt : 'Novi recept',
                      imageUrl: image != null ? 'https://kulinar.app/storage/$image' : null,
                      color: i == 0 ? Colors.green : kOrange,
                      ratingAverage: (p['rating_average'] as num?)?.toDouble() ?? 0,
                      ratingCount: (p['rating_count'] as num?)?.toInt() ?? 0,
                      slug: slug,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kOrange, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPostTile extends StatelessWidget {
  final String title;
  final String sub;
  final String? imageUrl;
  final Color color;
  final double ratingAverage;
  final int ratingCount;
  final String? slug;

  const _MiniPostTile({
    required this.title,
    required this.sub,
    required this.color,
    this.imageUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: slug != null ? () => context.push('/posts/$slug') : null,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(sub,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < ratingAverage.round() ? Icons.star : Icons.star_border,
                      color: ratingAverage > 0 ? kOrange : Colors.white24,
                      size: 11,
                    )),
                    if (ratingAverage > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$ratingAverage',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.circle, color: color, size: 8),
        ],
      ),
    ),   // closes Container
    );   // closes GestureDetector
  }

  Widget _placeholder() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kOrange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.restaurant_menu, color: kOrange, size: 18),
      );
}

class _Features extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 60),
      color: const Color(0xFF111111),
      child: Column(
        children: [
          const Text('Sve što ti treba,', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('na jednom mjestu.', style: TextStyle(color: kOrange, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 48),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: const [
              _FeatureCard(icon: Icons.menu_book_outlined, title: 'Tvoj receptar', desc: 'Spremi sve recepte na jednom mjestu.'),
              _FeatureCard(icon: Icons.calculate_outlined, title: 'Kalkulator', desc: 'Točne količine, savršeni rezultati.'),
              _FeatureCard(icon: Icons.settings_outlined, title: 'Postavke', desc: 'Prilagodi sve po svom stilu.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOrange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kOrange, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class _Stats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final statsAsync = ref.watch(landingStatsProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 60),
      color: kBg,
      child: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kOrange, strokeWidth: 2)),
        error: (_, __) => Wrap(
          spacing: 24, runSpacing: 24, alignment: WrapAlignment.center,
          children: const [
            _StatItem(value: '500+', label: 'recepata'),
            _StatItem(value: '—', label: 'korisnika'),
            _StatItem(value: '4.9 ★', label: 'prosječna ocjena'),
          ],
        ),
        data: (stats) {
          final userCount = stats['user_count'] as int? ?? 0;
          final postCount = stats['post_count'] as int? ?? 0;
          String fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k+' : '$n+';
          return Wrap(
            spacing: 24, runSpacing: 24, alignment: WrapAlignment.center,
            children: [
              _StatItem(value: fmt(postCount), label: 'recepata'),
              _StatItem(value: fmt(userCount), label: 'korisnika'),
              const _StatItem(value: '4.9 ★', label: 'prosječna ocjena'),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOrange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: kOrange, fontSize: 40, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }
}

class _RecentPosts extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final postsAsync = ref.watch(landingPostsProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 60),
      color: const Color(0xFF111111),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Zadnji recepti',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Svježe iz kuhinje.',
              style: TextStyle(color: kOrange, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          postsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: kOrange, strokeWidth: 2)),
            error: (_, __) => const Text('Greška pri učitavanju.',
                style: TextStyle(color: Colors.white38)),
            data: (posts) {
              if (posts.isEmpty) {
                return const Text('Još nema recepata.',
                    style: TextStyle(color: Colors.white38));
              }
              return Column(
                children: [
                  ...posts.map((post) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LandingRecipeCard(post: post),
                      )),
                  const SizedBox(height: 24),
                  Builder(builder: (context) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/recepti'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.menu_book_outlined, size: 20),
                      label: const Text('Svi recepti',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LandingRecipeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  const _LandingRecipeCard({required this.post});

  @override
  ConsumerState<_LandingRecipeCard> createState() => _LandingRecipeCardState();
}

class _LandingRecipeCardState extends ConsumerState<_LandingRecipeCard> {
  bool _expanded = false;
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final auth = ref.watch(authProvider);
    final imageUrl = post['image'] != null
        ? 'https://kulinar.app/storage/${post['image']}'
        : null;
    final title = post['title'] as String? ?? '';
    final content = post['excerpt'] as String? ?? post['content'] as String? ?? '';
    final slug = post['slug'] as String? ?? '';
    final authorName = post['user']?['name'] as String? ?? '';
    final postId = (post['id'] as num?)?.toInt() ?? 0;
    final isOwner = post['is_owner'] == true;
    final avgRating = _avgRating ?? (post['rating_average'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = _ratingCount ?? (post['rating_count'] as num?)?.toInt() ?? 0;
    final myRating = _myRating ?? post['my_rating'] as int?;

    // Skrati tekst na ~120 znakova
    final shortContent = content.length > 120 ? '${content.substring(0, 120)}…' : content;
    final needsExpand = content.length > 120;

    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slika
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgPlaceholder(),
              ),
            )
          else
            _imgPlaceholder(rounded: true),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                const SizedBox(height: 4),
                Text(authorName,
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 10),
                // Rating row
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < avgRating.round() ? Icons.star : Icons.star_border,
                      color: avgRating > 0 ? kOrange : Colors.white24,
                      size: 16,
                    )),
                    if (avgRating > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$avgRating${ratingCount > 0 ? ' ($ratingCount)' : ''}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                if (auth.isLoggedIn && !isOwner && postId > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        myRating != null ? 'Tvoja ocjena:' : 'Ocijeni:',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
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
                              color: star <= (myRating ?? 0) ? kOrange : Colors.white24,
                              size: 22,
                            ),
                          ),
                        );
                      }),
                      if (_ratingLoading) ...[
                        const SizedBox(width: 6),
                        const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(color: kOrange, strokeWidth: 1.5),
                        ),
                      ],
                    ],
                  ),
                ],
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _expanded ? content : shortContent,
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6),
                  ),
                  if (needsExpand) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded ? 'Manje ▲' : 'Više ▼',
                        style: const TextStyle(
                            color: kOrange, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder({bool rounded = false}) => ClipRRect(
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.zero,
        child: Container(
          width: double.infinity,
          height: 160,
          color: kOrange.withOpacity(0.1),
          child: const Icon(Icons.restaurant, color: kOrange, size: 48),
        ),
      );
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      color: const Color(0xFF0D0D0D),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('© 2026 Kulinar.app · Sva prava pridržana', style: TextStyle(color: Colors.white24, fontSize: 12)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.push('/privacy'),
            child: const Text('Politika privatnosti', style: TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.white38)),
          ),
        ],
      ),
    );
  }
}
