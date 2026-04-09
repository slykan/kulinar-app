import 'package:flutter/material.dart';

class KobasiceCalculatorScreen extends StatefulWidget {
  const KobasiceCalculatorScreen({super.key});

  @override
  State<KobasiceCalculatorScreen> createState() => _KobasiceCalculatorScreenState();
}

class _KobasiceCalculatorScreenState extends State<KobasiceCalculatorScreen> {
  final _controller = TextEditingController(text: '10');
  double _kg = 10;

  static const _spices = [
    ('Sol', 1.8),
    ('Šećer', 0.5),
    ('Slatka paprika', 0.5),
    ('Ljuta paprika', 0.5),
    ('Biber', 0.3),
    ('Bijeli luk', 0.5),
  ];

  void _onChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      setState(() => _kg = parsed);
    }
  }

  String _format(double grams) {
    if (grams >= 1000) {
      return '${(grams / 1000).toStringAsFixed(2)} kg';
    }
    return '${grams.toStringAsFixed(0)} g';
  }

  double _grams(double percent) => _kg * 1000 * percent / 100;

  double get _total => _spices.fold(0, (sum, s) => sum + _grams(s.$2));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator kobasica')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Količina mesa', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onChanged,
                    decoration: const InputDecoration(
                      suffixText: 'kg',
                      hintText: 'Npr. 10',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Začini', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ..._spices.asMap().entries.map((e) {
                    final (name, percent) = e.value;
                    final isLast = e.key == _spices.length - 1;
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
                                '$percent%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  _format(_grams(percent)),
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(height: 1, indent: 16, endIndent: 16,
                              color: Theme.of(context).colorScheme.outlineVariant),
                      ],
                    );
                  }),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Ukupno začina',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _format(_total),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    Expanded(
                      child: Text(
                        'Preporučeni promjer crijeva: 34 mm',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
