import 'package:flutter/material.dart';

class TripiceCalculatorScreen extends StatefulWidget {
  const TripiceCalculatorScreen({super.key});

  @override
  State<TripiceCalculatorScreen> createState() => _TripiceCalculatorScreenState();
}

class _TripiceCalculatorScreenState extends State<TripiceCalculatorScreen> {
  final _controller = TextEditingController(text: '500');
  double _grams = 500;

  // Baza: 500g tripica / 3 osobe
  static const _baseGrams = 500.0;

  static const _ingredients = [
    ('Tripice', 500.0, 'g'),
    ('Mrkva', 0.5, 'kom'),
    ('Hamburger', 100.0, 'g'),
    ('Slanina', 100.0, 'g'),
    ('Koncentrat rajčice', 1.0, 'mž'),
    ('Slatka paprika', 1.0, 'mž'),
    ('Luk', 2.0, 'kom'),
    ('Češnjak', 2.0, 'čš'),
    ('Mrvice', 2.0, 'vž'),
    ('Dodatak jelu', 2.0, 'vž'),
    ('Brašno', 1.0, 'vž'),
    ('Tucana paprika', 1.0, 'mmž'),
    ('Sol', 1.0, 'mž'),
    ('Juha kocka', 1.0, 'kom'),
    ('Voda', 1500.0, 'ml'),
    ('Celer', 1.0, 'kom'),
    ('Peršin', 1.0, 'vezica'),
  ];

  void _onChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      setState(() => _grams = parsed);
    }
  }

  String _scale(double base, String unit) {
    final factor = _grams / _baseGrams;
    final scaled = base * factor;

    if (unit == 'g' || unit == 'ml') {
      if (scaled >= 1000) {
        final label = unit == 'g' ? 'kg' : 'l';
        return '${(scaled / 1000).toStringAsFixed(2)} $label';
      }
      return '${scaled.toStringAsFixed(0)} $unit';
    }

    // Za komade i žlice — prikaz s decimalama ako nije cijeli broj
    if (scaled == scaled.roundToDouble()) {
      return '${scaled.toStringAsFixed(0)} $unit';
    }
    return '${scaled.toStringAsFixed(1)} $unit';
  }

  double get _persons => _grams / _baseGrams * 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator tripica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Količina tripica', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onChanged,
              decoration: const InputDecoration(
                suffixText: 'g',
                hintText: 'Npr. 500',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Za ~${_persons.toStringAsFixed(1)} osobe',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text('Sastojci', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _ingredients.asMap().entries.map((e) {
                  final (name, base, unit) = e.value;
                  final isLast = e.key == _ingredients.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ],
        ),
      ),
    );
  }
}
