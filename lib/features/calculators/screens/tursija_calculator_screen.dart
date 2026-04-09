import 'package:flutter/material.dart';

class TursijaCalculatorScreen extends StatefulWidget {
  const TursijaCalculatorScreen({super.key});

  @override
  State<TursijaCalculatorScreen> createState() => _TursijaCalculatorScreenState();
}

class _TursijaCalculatorScreenState extends State<TursijaCalculatorScreen> {
  final _controller = TextEditingController(text: '1');
  double _octakL = 1;

  // Baza: 1L octa
  static const _ingredients = [
    ('Ocat', 1.0, 'l'),
    ('Voda', 3.0, 'l'),
    ('Sol', 150.0, 'g'),       // 15 dkg = 150g
    ('Šećer', 250.0, 'g'),     // 25 dkg = 250g
    ('Biber u zrnu', 2.0, 'vž'),
    ('Lovor', 3.0, 'list'),    // nije u excelu, ali standardno
  ];

  void _onChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      setState(() => _octakL = parsed);
    }
  }

  String _scale(double base, String unit) {
    final scaled = base * _octakL;

    if (unit == 'g') {
      if (scaled >= 1000) return '${(scaled / 1000).toStringAsFixed(2)} kg';
      return '${scaled.toStringAsFixed(0)} g';
    }
    if (unit == 'l') {
      if (scaled < 1) return '${(scaled * 1000).toStringAsFixed(0)} ml';
      return '${scaled.toStringAsFixed(2)} l';
    }
    if (scaled == scaled.roundToDouble()) {
      return '${scaled.toStringAsFixed(0)} $unit';
    }
    return '${scaled.toStringAsFixed(1)} $unit';
  }

  double get _totalLiters => (1 + 3) * _octakL;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator turšije')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Količina octa', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onChanged,
              decoration: const InputDecoration(
                suffixText: 'L',
                hintText: 'Npr. 1',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ukupno salamure: ${_totalLiters.toStringAsFixed(1)} L',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text('Salamura', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _ingredients.asMap().entries.map((e) {
                  final (name, base, unit) = e.value;
                  final isLast = e.key == _ingredients.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(name, style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            Text(
                              _scale(base, unit),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Omjer octa i vode je 1:3'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
