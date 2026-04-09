import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/providers/auth_provider.dart';
import '../../core/api/api_client.dart';

const kOrange = Color(0xFFE85D04);
const kBg = Color(0xFF181818);
const kCard = Color(0xFF242424);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?['name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final client = ref.read(apiClientProvider);
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      };
      if (_passwordController.text.isNotEmpty) {
        body['password'] = _passwordController.text;
        body['password_confirmation'] = _passwordConfirmController.text;
      }

      final response = await client.dio.put('/me', data: body);
      final updatedUser = response.data as Map<String, dynamic>;

      ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil ažuriran!'), backgroundColor: kOrange),
        );
        _passwordController.clear();
        _passwordConfirmController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Obriši račun', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Jesi li siguran? Ova radnja je nepovratna — svi tvoji recepti i podaci bit će izbrisani.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Odustani', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.delete('/me');
      await ref.read(authStorageProvider).deleteToken();
      ref.read(authProvider.notifier).clearUser();
      if (mounted) context.go('/landing');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(backgroundColor: kBg);
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: kBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/landing');
            },
            icon: const Icon(Icons.logout, size: 18, color: Colors.white54),
            label: const Text('Odjava', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: kOrange.withOpacity(0.2),
                      backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
                      child: user['avatar'] == null
                          ? Text(
                              (user['name'] as String? ?? 'K')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 36, color: kOrange, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    if (user['google_id'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.blue, size: 12),
                            SizedBox(width: 4),
                            Text('Google račun', style: TextStyle(color: Colors.blue, fontSize: 11)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('Osnovni podaci', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ime i prezime',
                  prefixIcon: Icon(Icons.person_outline, color: kOrange),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ime je obavezno' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email adresa',
                  prefixIcon: Icon(Icons.email_outlined, color: kOrange),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email je obavezan';
                  if (!v.contains('@')) return 'Nevažeći email';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              const Text('Promjena lozinke', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 4),
              const Text('Ostavi prazno ako ne mijenjаš lozinku', style: TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Nova lozinka',
                  prefixIcon: const Icon(Icons.lock_outline, color: kOrange),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 8) return 'Minimalno 8 znakova';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordConfirmController,
                style: const TextStyle(color: Colors.white),
                obscureText: !_showPassword,
                decoration: const InputDecoration(
                  labelText: 'Potvrdi lozinku',
                  prefixIcon: Icon(Icons.lock_outline, color: kOrange),
                ),
                validator: (v) {
                  if (_passwordController.text.isNotEmpty && v != _passwordController.text) {
                    return 'Lozinke se ne podudaraju';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Spremi
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isLoading ? 'Sprema...' : 'Spremi izmjene',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Opasna zona
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Opasna zona', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      'Brisanjem računa trajno uklanjаš sve svoje recepte i podatke.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _deleteAccount,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.delete_forever_outlined),
                        label: const Text('Obriši račun', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
