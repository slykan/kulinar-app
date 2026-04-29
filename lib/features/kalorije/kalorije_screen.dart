import 'package:flutter/material.dart';

const _kBg = Color(0xFF181818);
const _kSurface = Color(0xFF242424);
const _kCard = Color(0xFF2C2C2C);
const _kOrange = Color(0xFFE85D04);

class _Item {
  final String name;
  final int kcal;
  final double uh;
  final double proteini;
  final double masti;
  const _Item(this.name, this.kcal, this.uh, this.proteini, this.masti);
}

class _Category {
  final String name;
  final String emoji;
  final List<_Item> items;
  const _Category(this.name, this.emoji, this.items);
}

const _categories = [
  _Category('Mliječni proizvodi', '🥛', [
    _Item('Mlijeko (0,9 % masti)', 40, 4.7, 3.3, 0.9),
    _Item('Mlijeko (3,2 % masti)', 66, 4.7, 3.3, 3.2),
    _Item('Jogurt (obični)', 40, 5, 4, 4),
    _Item('Kiselo vrhnje', 192, 3, 3, 18),
    _Item('Slatko vrhnje', 317, 2, 3, 32),
    _Item('Puding od čokolade', 134, 21, 3.5, 4),
    _Item('Sirni namazi (23% masti)', 115, 6, 13, 5),
    _Item('Topljeni sir (45% masti)', 385, 6, 14, 24),
    _Item('Tvrdi sir (45% masti)', 372, 3, 25, 28),
    _Item('Svježi kravlji sir', 72, 4, 15, 3),
    _Item('Zrnati sir', 92, 1, 13, 4),
  ]),
  _Category('Meso', '🥩', [
    _Item('Bubrezi (teleći)', 121, 1, 15, 6),
    _Item('Hrenovke (govedina + svinjetina)', 320, 2, 11, 29),
    _Item('Hrenovke (pileće)', 258, 7, 13, 20),
    _Item('Janjetina (srednje masna)', 211, 0, 19, 15),
    _Item('Jetra (teleća)', 137, 4, 18, 4),
    _Item('Jetrena pašteta', 440, 1, 12, 40),
    _Item('Kobasica (prosječno)', 324, 1, 11, 30),
    _Item('Konjetina', 89, 0, 16, 2),
    _Item('Krvavice', 424, 0, 13, 39),
    _Item('Kunić', 132, 1, 16, 6),
    _Item('Mesni narezak (svinjsko meso)', 424, 4, 12, 40),
    _Item('Mljeveno, miješano meso', 253, 0, 20, 19),
    _Item('Ovčetina', 246, 0, 13, 24),
    _Item('Piletina (bijelo meso bez kostiju)', 144, 0, 21, 3),
    _Item('Puretina (bijelo meso bez kostiju)', 231, 0, 22, 5),
    _Item('Salama parizer', 523, 1, 17, 47),
    _Item('Salama, pileća, pureća', 197, 1, 16, 14),
    _Item('Slanina', 605, 0, 8, 60),
    _Item('Srnetina', 123, 0, 21, 3),
    _Item('Svinjetina', 345, 0, 18, 27),
    _Item('Šunka dimljena i pršut', 385, 0, 18, 33),
    _Item('Šunka (kuhana)', 274, 0, 19, 20),
    _Item('Šunka pureća/pileća', 128, 0, 19, 5),
    _Item('Teletina', 105, 0, 21, 3),
  ]),
  _Category('Riba i morski plodovi', '🐟', [
    _Item('Bakalar', 76, 0, 17, 1),
    _Item('Dagnja', 66, 2, 12, 2),
    _Item('Grgeč', 75, 0, 15, 2),
    _Item('Haringa', 155, 0, 13, 10),
    _Item('Inćun', 89, 0, 17, 3),
    _Item('Jastog', 86, 1, 16, 2),
    _Item('Jegulja', 209, 1, 9, 18),
    _Item('Kamenica (ostriga)', 49, 4, 6, 1),
    _Item('Lignja', 77, 1, 16, 1),
    _Item('Losos', 217, 0, 20, 14),
    _Item('Pastrva', 112, 0, 18, 2),
    _Item('Sardine u ulju', 240, 1, 24, 14),
    _Item('Skuša', 195, 0, 19, 12),
    _Item('Šaran', 65, 0, 10, 3),
    _Item('Škampi', 91, 0, 17, 2),
    _Item('Štuka', 85, 0, 17, 2),
    _Item('Tunj u ulju', 303, 0, 24, 21),
  ]),
  _Category('Kruh i žitarice', '🍞', [
    _Item('Crni kruh', 250, 51, 6, 1),
    _Item('Dvopek', 397, 77, 10, 1),
    _Item('Griz', 370, 75, 10, 1),
    _Item('Kolači od samog tijesta', 314, 39, 7, 13),
    _Item('Kokice', 376, 72, 13, 4),
    _Item('Kruh sa cijelim zrnima', 240, 46, 7, 1),
    _Item('Kukuruzni kruh', 220, 31, 5, 9),
    _Item('Kukuruzne pahuljice', 388, 83, 6, 1),
    _Item('Musli', 371, 68, 11, 6),
    _Item('Polubijeli kruh', 252, 52, 3, 1),
    _Item('Pšenično brašno', 370, 71, 12, 2),
    _Item('Raženo brašno', 356, 35, 9, 1),
    _Item('Riža ljuštena', 368, 79, 7, 1),
    _Item('Riža neljuštena', 371, 75, 7, 2),
    _Item('Soja u zrnu', 427, 26, 38, 19),
    _Item('Sojin sir (tofu)', 72, 2, 8, 4),
    _Item('Tjestenina sa jajima', 390, 72, 13, 3),
    _Item('Zobene pahuljice', 402, 66, 14, 7),
  ]),
  _Category('Krumpir', '🥔', [
    _Item('Čips od krumpira', 568, 50, 5, 40),
    _Item('Krumpir', 85, 19, 2, 0),
    _Item('Kuhani valjušci od krumpirova tijesta', 117, 27, 1, 0),
    _Item('Pomfrit', 270, 34, 4, 12),
  ]),
  _Category('Voće', '🍎', [
    _Item('Ananas', 56, 13, 0, 0),
    _Item('Banane', 99, 23, 1, 0),
    _Item('Borovnice', 62, 14, 1, 1),
    _Item('Breskve', 46, 11, 1, 0),
    _Item('Dinje', 24, 5, 1, 0),
    _Item('Grožđe', 70, 16, 1, 0),
    _Item('Grejp', 42, 10, 1, 0),
    _Item('Jabuka', 52, 12, 0, 0),
    _Item('Jagode', 36, 7, 1, 0),
    _Item('Kivi', 55, 11, 1, 1),
    _Item('Kruške', 55, 12, 0, 0),
    _Item('Lubenica', 24, 5, 1, 0),
    _Item('Maline', 40, 8, 1, 0),
    _Item('Mandarine', 48, 11, 1, 0),
    _Item('Marelice', 54, 12, 1, 0),
    _Item('Naranče', 54, 9, 1, 0),
    _Item('Ribizl (crveni)', 45, 10, 1, 0),
    _Item('Ribizl (crni)', 63, 14, 1, 0),
    _Item('Šljive', 58, 14, 1, 0),
    _Item('Trešnje', 57, 13, 1, 0),
  ]),
  _Category('Povrće', '🥦', [
    _Item('Artičoke', 23, 5, 1, 0),
    _Item('Brokula', 33, 4, 3, 0),
    _Item('Cikla', 37, 8, 2, 0),
    _Item('Cvjetača', 28, 4, 2, 0),
    _Item('Celer', 38, 7, 2, 0),
    _Item('Grah', 110, 21, 7, 1),
    _Item('Grašak', 93, 14, 7, 1),
    _Item('Kelj', 46, 5, 4, 1),
    _Item('Krastavci', 10, 2, 1, 0),
    _Item('Kupus (kiseli)', 26, 4, 2, 0),
    _Item('Kupus (slatki)', 52, 7, 4, 1),
    _Item('Luk', 42, 9, 1, 0),
    _Item('Mrkva', 35, 7, 1, 0),
    _Item('Paprika', 28, 5, 1, 0),
    _Item('Patlidžan', 26, 5, 1, 0),
    _Item('Poriluk', 38, 6, 2, 0),
    _Item('Rajčica', 19, 3, 1, 0),
    _Item('Šampinjoni', 24, 3, 3, 0),
    _Item('Šparoga', 20, 3, 2, 0),
    _Item('Špinat', 23, 2, 2, 0),
    _Item('Zelena salata', 14, 2, 1, 0),
    _Item('Zelje', 25, 4, 1, 0),
  ]),
  _Category('Ulja i masti', '🫙', [
    _Item('Maslac', 755, 0, 1, 83),
    _Item('Margarin', 720, 0, 0, 81),
    _Item('Majoneza', 761, 3, 1, 80),
    _Item('Majoneza light', 341, 6, 1, 35),
    _Item('Svinjska mast', 900, 0, 0, 100),
    _Item('Biljna mast', 753, 9, 14, 74),
    _Item('Tartar umak', 480, 2, 1, 52),
    _Item('Ulje maslinovo', 900, 0, 0, 100),
    _Item('Ulje repino', 900, 0, 0, 100),
    _Item('Ulje od suncokreta', 928, 0, 0, 100),
    _Item('Ulje od kukuruznih klica', 930, 0, 0, 100),
  ]),
  _Category('Jaja', '🥚', [
    _Item('Cijelo jaje', 167, 1, 13, 11),
    _Item('Žutanjak', 377, 0, 16, 32),
    _Item('Bjelanjak', 54, 1, 11, 0),
  ]),
  _Category('Slatkiši i kolači', '🍫', [
    _Item('Biskvit masni', 462, 52, 5, 26),
    _Item('Bomboni tvrdi obični', 390, 91, 0, 0),
    _Item('Bomboni voćni', 292, 73, 0, 0),
    _Item('Čokolada mliječna', 563, 55, 9, 33),
    _Item('Čokolada za kuhanje', 564, 63, 14, 28),
    _Item('Čokoladni bomboni', 490, 68, 5, 22),
    _Item('Čokoladni namaz (Nutella)', 534, 59, 7, 30),
    _Item('Guma za žvakanje', 280, 70, 0, 0),
    _Item('Gumeni bomboni', 345, 88, 0, 0),
    _Item('Kakao prah', 232, 55, 20, 14),
    _Item('Keks sa čokoladnim preljevom', 530, 68, 6, 28),
    _Item('Marmelada', 261, 66, 0, 0),
    _Item('Med', 303, 81, 0, 0),
    _Item('Napolitanke', 550, 62, 4, 32),
    _Item('Piškoti', 393, 70, 12, 7),
    _Item('Plazma keks', 440, 70, 12, 12),
    _Item('Puding u prahu', 380, 95, 0, 0),
    _Item('Šećer kristal', 391, 100, 0, 0),
  ]),
  _Category('Pića', '🥤', [
    _Item('Limunada', 49, 12, 0, 0),
    _Item('Sok od jabuke', 47, 12, 0, 0),
    _Item('Sok od naranče', 47, 11, 1, 0),
    _Item('Sok od grejpa', 40, 9, 1, 0),
    _Item('Sok od ribiza', 50, 12, 0, 0),
    _Item('Sok od mrkve', 28, 6, 1, 0),
    _Item('Sok od grožđa', 71, 18, 0, 0),
    _Item('Svijetlo pivo', 45, 4, 1, 0),
    _Item('Crno vino', 66, 0, 0, 0),
    _Item('Bijelo vino', 70, 0, 0, 0),
    _Item('Rakija', 185, 0, 0, 0),
    _Item('Pjenušavo vino', 84, 3, 0, 0),
    _Item('Viski', 250, 0, 0, 0),
  ]),
];

String _fmt(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class KalorijeScreen extends StatefulWidget {
  const KalorijeScreen({super.key});

  @override
  State<KalorijeScreen> createState() => _KalorijeScreenState();
}

class _KalorijeScreenState extends State<KalorijeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Category> get _filtered {
    if (_query.isEmpty) return _categories;
    final q = _query.toLowerCase();
    return _categories
        .map((cat) => _Category(
              cat.name,
              cat.emoji,
              cat.items.where((item) => item.name.toLowerCase().contains(q)).toList(),
            ))
        .where((cat) => cat.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    final List<Widget> rows = [];
    for (final cat in filtered) {
      rows.add(_SectionHeader(emoji: cat.emoji, name: cat.name));
      rows.add(const _TableHeader());
      for (var i = 0; i < cat.items.length; i++) {
        rows.add(_TableRow(item: cat.items[i], even: i.isEven));
      }
      rows.add(const SizedBox(height: 8));
    }

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Tablica kalorija',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
        ),
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pretraži namirnice…',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: _kCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 56, color: Colors.white24),
                  SizedBox(height: 12),
                  Text('Nema rezultata', style: TextStyle(color: Colors.white38, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: rows.length,
              itemBuilder: (_, i) => rows[i],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String name;
  const _SectionHeader({required this.emoji, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kOrange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              color: _kOrange,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 4,
            child: Text('Namirnica',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          _ColHead('kcal'),
          _ColHead('UH g'),
          _ColHead('Prot. g'),
          _ColHead('Masti g'),
        ],
      ),
    );
  }
}

class _ColHead extends StatelessWidget {
  final String label;
  const _ColHead(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final _Item item;
  final bool even;
  const _TableRow({required this.item, required this.even});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: even ? _kCard : _kCard.withOpacity(0.6),
        border: const Border(
          left: BorderSide(color: Colors.white10),
          right: BorderSide(color: Colors.white10),
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.name,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          _ValCell('${item.kcal}', isKcal: true),
          _ValCell(_fmt(item.uh)),
          _ValCell(_fmt(item.proteini)),
          _ValCell(_fmt(item.masti)),
        ],
      ),
    );
  }
}

class _ValCell extends StatelessWidget {
  final String value;
  final bool isKcal;
  const _ValCell(this.value, {this.isKcal = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Text(
        value,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isKcal ? _kOrange : Colors.white54,
          fontSize: 13,
          fontWeight: isKcal ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
