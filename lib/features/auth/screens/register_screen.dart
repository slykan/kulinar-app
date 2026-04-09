import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/turnstile_widget.dart';
import '../providers/auth_provider.dart';

const _siteKey = '0x4AAAAAAA272FNBOuqwbiqe';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _turnstileToken = kIsWeb ? 'web-bypass' : null;
  bool _turnstileReady = kIsWeb ? true : false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_turnstileToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Čekaj CAPTCHA verifikaciju...')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
      turnstileToken: _turnstileToken!,
    );

    if (success && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Kreiraj račun',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pridruži se Kulinar.app zajednici',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  if (authState.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade700),
                      ),
                      child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
                    ),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ime i prezime',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Unesite ime' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Unesite email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Lozinka',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                    validator: (v) => v == null || v.length < 8 ? 'Minimum 8 znakova' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Potvrdi lozinku',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                    validator: (v) => v != _passwordController.text ? 'Lozinke se ne poklapaju' : null,
                  ),
                  const SizedBox(height: 20),

                  // Cloudflare Turnstile
                  TurnstileWidget(
                    siteKey: _siteKey,
                    onTokenReceived: (token) {
                      setState(() {
                        _turnstileToken = token;
                        _turnstileReady = true;
                      });
                    },
                    onTokenExpired: () {
                      setState(() {
                        _turnstileToken = null;
                        _turnstileReady = false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: (authState.isLoading || !_turnstileReady) ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Registriraj se'),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Već imaš račun? Prijavi se', style: TextStyle(color: Color(0xFFE85D04))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
