import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (emoji: '🌭', title: 'Kobasice za pečenje', subtitle: 'Začini prema kg mesa', route: '/kalkulatori/kobasice'),
      (emoji: '🍲', title: 'Tripice', subtitle: 'Sastojci prema gramima', route: '/kalkulatori/tripice'),
      (emoji: '🥒', title: 'Turšija', subtitle: 'Salamura prema litrama octa', route: '/kalkulatori/tursija'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulatori')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.push(item.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85D04).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE85D04), width: 1),
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
                          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFE85D04)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
