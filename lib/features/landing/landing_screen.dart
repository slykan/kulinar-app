import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const kOrange = Color(0xFFE85D04);
const kBg = Color(0xFF181818);
const kCard = Color(0xFF242424);

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Navbar(),
            _Hero(),
            _Features(),
            _Stats(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          if (MediaQuery.of(context).size.width > 700) ...[
            _NavLink(label: 'Recepti', onTap: () => context.go('/')),
            _NavLink(label: 'Kalkulator', onTap: () => context.go('/kalkulatori')),
            _NavLink(label: 'Registracija', onTap: () => context.go('/register')),
            const SizedBox(width: 16),
          ],
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
                Expanded(flex: 5, child: _HeroContent()),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: _HeroVisual()),
              ],
            )
          : Column(
              children: [
                _HeroContent(),
                const SizedBox(height: 40),
                _HeroVisual(),
              ],
            ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            SizedBox(
              width: 100,
              height: 32,
              child: Stack(
                children: List.generate(4, (i) => Positioned(
                  left: i * 22.0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: kOrange.withOpacity(0.3),
                    child: Text(['👨', '👩', '🧑', '👨'][i], style: const TextStyle(fontSize: 14)),
                  ),
                )),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: List.generate(5, (_) => const Icon(Icons.star, color: kOrange, size: 14))),
                const SizedBox(height: 2),
                const Text('Pridružilo se 10.000+ kuhara', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Text('Dobrodošao natrag,', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const Text('Majstore! 👋', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const Text('Vrijeme je za nešto fino.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MiniStatCard(icon: Icons.restaurant_menu, value: '12', label: 'Aktivni recepti')),
              const SizedBox(width: 12),
              Expanded(child: _MiniStatCard(icon: Icons.trending_up, value: '5', label: 'Dovršeni ovaj tjedan')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Nedavni recepti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _MiniPostTile(emoji: '🐟', title: 'Fiš paprikaš', sub: 'Završen · Jučer', color: Colors.green),
          const SizedBox(height: 8),
          _MiniPostTile(emoji: '🌭', title: 'Čajna kobasica', sub: 'U tijeku · 15 dana', color: kOrange),
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
  final String emoji;
  final String title;
  final String sub;
  final Color color;

  const _MiniPostTile({required this.emoji, required this.title, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.circle, color: color, size: 10),
        ],
      ),
    );
  }
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

class _Stats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 60),
      color: kBg,
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: const [
          _StatItem(value: '500+', label: 'recepata'),
          _StatItem(value: '10k+', label: 'korisnika'),
          _StatItem(value: '4.9 ★', label: 'prosječna ocjena'),
        ],
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

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      color: const Color(0xFF0D0D0D),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('© 2026 Kulinar.app · Sva prava pridržana', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
