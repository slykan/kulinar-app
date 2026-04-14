import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../posts/widgets/recent_recipes_sidebar.dart';

const _kBg = Color(0xFF181818);
const _kCard = Color(0xFF2C2C2C);
const _kOrange = Color(0xFFE85D04);

class CalculatorsScreen extends ConsumerWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 960;
    final items = [
      (emoji: '🌭', title: 'Kobasice za pečenje', subtitle: 'Začini prema kg mesa', route: '/kalkulatori/kobasice'),
      (emoji: '🍲', title: 'Tripice', subtitle: 'Sastojci prema gramima', route: '/kalkulatori/tripice'),
      (emoji: '🥒', title: 'Turšija', subtitle: 'Salamura prema litrama octa', route: '/kalkulatori/tursija'),
    ];

    final mainContent = ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return InkWell(
          onTap: () => context.push(item.route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _kOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(item.subtitle,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Kalkulatori', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: mainContent),
                Container(
                  width: 276,
                  color: _kBg,
                  padding: const EdgeInsets.fromLTRB(0, 8, 24, 24),
                  child: const RecentRecipesSidebar(),
                ),
              ],
            )
          : mainContent,
    );
  }
}
