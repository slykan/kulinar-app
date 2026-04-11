import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kOrange = Color(0xFFE85D04);
const _kCard = Color(0xFF242424);
const _kCardDark = Color(0xFF1E1E1E);

class _IngRow {
  final TextEditingController nameCtrl;
  final TextEditingController quantityCtrl;
  final TextEditingController unitCtrl;

  _IngRow({String name = '', String quantity = '', String unit = ''})
      : nameCtrl = TextEditingController(text: name),
        quantityCtrl = TextEditingController(text: quantity),
        unitCtrl = TextEditingController(text: unit);

  void dispose() {
    nameCtrl.dispose();
    quantityCtrl.dispose();
    unitCtrl.dispose();
  }
}

class IngredientsEditor extends StatefulWidget {
  final int? initialServings;
  final List<Map<String, dynamic>>? initialIngredients;

  const IngredientsEditor({
    super.key,
    this.initialServings,
    this.initialIngredients,
  });

  @override
  State<IngredientsEditor> createState() => IngredientsEditorState();
}

class IngredientsEditorState extends State<IngredientsEditor> {
  final _servingsController = TextEditingController();
  final List<_IngRow> _rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialServings != null) {
      _servingsController.text = widget.initialServings.toString();
    }
    if (widget.initialIngredients != null &&
        widget.initialIngredients!.isNotEmpty) {
      for (final ing in widget.initialIngredients!) {
        _rows.add(_IngRow(
          name: ing['name']?.toString() ?? '',
          quantity: ing['quantity']?.toString() ?? '',
          unit: ing['unit']?.toString() ?? '',
        ));
      }
    }
  }

  @override
  void dispose() {
    _servingsController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  /// Returns (servings, ingredientsJson) — ingredientsJson is null if empty
  (int?, String?) getData() {
    final servings = int.tryParse(_servingsController.text.trim());
    final ingredients = _rows
        .where((r) => r.nameCtrl.text.trim().isNotEmpty)
        .map((r) => {
              'name': r.nameCtrl.text.trim(),
              'quantity': r.quantityCtrl.text.trim(),
              'unit': r.unitCtrl.text.trim(),
            })
        .toList();
    final json = ingredients.isNotEmpty ? jsonEncode(ingredients) : null;
    return (servings, json);
  }

  void _addRow() {
    setState(() => _rows.add(_IngRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kOrange),
        ),
        filled: true,
        fillColor: _kCardDark,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header naslov
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, color: _kOrange, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Namirnice',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ],
            ),
          ),

          // Servings — prominentni red
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_outline,
                      color: _kOrange, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recept je za',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _servingsController,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      hintText: '4',
                      hintStyle: const TextStyle(
                          color: Colors.white24, fontSize: 16),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: _kCardDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'osoba',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),

          // Tablica namirnica
          const Divider(height: 1, color: Colors.white10),

          if (_rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Nema dodanih namirnica',
                  style: TextStyle(color: Colors.white24, fontSize: 13),
                ),
              ),
            )
          else ...[
            // Column headers
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: const [
                  SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: Text('Namirnica',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: Text('Količina',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: Text('Jed.',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 32),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rows.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, i) {
                final row = _rows[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${i + 1}.',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: row.nameCtrl,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: _inputDec('Npr. Brašno'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.quantityCtrl,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: _inputDec('200'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.unitCtrl,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: _inputDec('g'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeRow(i),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.red, size: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          // Add row button
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: _addRow,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _kOrange.withOpacity(0.3), width: 1),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: _kOrange, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Dodaj namirnicu',
                      style: TextStyle(
                          color: _kOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
