import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _kBg = Color(0xFF181818);
const _kCard = Color(0xFF242424);
const _kOrange = Color(0xFFE85D04);

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Politika privatnosti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Section(
              title: 'Politika privatnosti',
              body: 'Zadnja izmjena: travanj 2026.\n\n'
                  'Kulinar.app ("mi", "naša aplikacija") posvećen je zaštiti vaše privatnosti. '
                  'Ovim dokumentom opisujemo koje podatke prikupljamo, kako ih koristimo i kako ih štitimo.',
            ),
            _Section(
              title: '1. Koji podaci se prikupljaju',
              body:
                  '• Ime i e-mail adresa pri registraciji\n'
                  '• Profilna fotografija (opcionalno)\n'
                  '• Recepti, komentari i ocjene koje sami objavljujete\n'
                  '• Tehnički podaci o uređaju (vrsta OS-a, verzija aplikacije) za dijagnostiku grešaka',
            ),
            _Section(
              title: '2. Kako koristimo vaše podatke',
              body:
                  '• Za pružanje usluge — prikaz vaših recepata i profila\n'
                  '• Za autentifikaciju — sigurna prijava u aplikaciju\n'
                  '• Za poboljšanje aplikacije — anonimni podaci o korištenju\n'
                  'Vaše podatke ne prodajemo trećim stranama.',
            ),
            _Section(
              title: '3. Pohrana podataka',
              body:
                  'Podaci se pohranjuju na sigurnim poslužiteljima unutar EU. '
                  'Koristimo industrijski standardne mjere zaštite (HTTPS, enkripcija lozinki). '
                  'Pristupni tokeni pohranjuju se lokalno na uređaju i nikada se ne dijele.',
            ),
            _Section(
              title: '4. Dijeljenje s trećim stranama',
              body:
                  'Vaši podaci se ne dijele s trećim stranama, osim:\n'
                  '• Google OAuth — pri prijavi putem Google računa (podliježe Google pravilima privatnosti)\n'
                  '• Zakonske obveze — ako to zahtijeva primjenjivo pravo',
            ),
            _Section(
              title: '5. Vaša prava',
              body:
                  'Imate pravo na:\n'
                  '• Uvid u podatke koje pohranjujemo o vama\n'
                  '• Ispravak netočnih podataka\n'
                  '• Brisanje računa i svih povezanih podataka\n\n'
                  'Za brisanje računa idite na: Profil → Izbriši račun.\n'
                  'Za ostale zahtjeve kontaktirajte nas na: kontakt@kulinar.app',
            ),
            _Section(
              title: '6. Kolačići i praćenje',
              body:
                  'Aplikacija ne koristi kolačiće za praćenje. '
                  'Web verzija (kulinar.app) može koristiti minimalne tehničke kolačiće neophodne za funkcioniranje.',
            ),
            _Section(
              title: '7. Djeca',
              body:
                  'Aplikacija nije namijenjena djeci mlađoj od 13 godina. '
                  'Ako saznamo da smo prikupili podatke od djeteta, odmah ćemo ih obrisati.',
            ),
            _Section(
              title: '8. Izmjene politike',
              body:
                  'Ovu politiku privatnosti možemo povremeno ažurirati. '
                  'O značajnim izmjenama obavijestit ćemo vas unutar aplikacije. '
                  'Nastavak korištenja aplikacije znači prihvaćanje izmijenjene politike.',
            ),
            _Section(
              title: '9. Kontakt',
              body:
                  'Za pitanja vezana uz privatnost pišite nam na:\n'
                  'kontakt@kulinar.app\n\n'
                  'Kulinar.app · Hrvatska',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _kOrange, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(body,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7)),
          ),
        ],
      ),
    );
  }
}
