import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/turnstile_widget.dart';
import '../providers/auth_provider.dart';
import '../../../core/storage/web_redirect.dart' if (dart.library.io) '../../../core/storage/web_redirect_stub.dart' as webRedirect;

const _siteKey = '0x4AAAAAAA272FNBOuqwbiqe';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _turnstileToken = kIsWeb ? 'web-bypass' : null;
  bool _turnstileReady = kIsWeb ? true : false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

    final success = await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      turnstileToken: _turnstileToken!,
    );

    if (success && mounted) context.go('/');
  }

  Future<void> _googleLogin() async {
    // Delay zbog CF Turnstile timing problema
    await Future.delayed(const Duration(milliseconds: 500));
    final authService = ref.read(authServiceProvider);
    final url = await authService.getGoogleAuthUrl(mobile: !kIsWeb);
    if (kIsWeb) {
      webRedirect.redirectTo(url);
    } else {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prijava')),
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
                  Center(
                    child: kIsWeb
                        ? Image.network('/logo.png', height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Color(0xFFE85D04), size: 80))
                        : Image.asset('assets/images/logo.png', height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Color(0xFFE85D04), size: 80)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dobrodošao natrag',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prijavi se na Kulinar.app',
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
                      child: Text(
                        authState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

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
                    validator: (v) => v == null || v.isEmpty ? 'Unesite lozinku' : null,
                    onFieldSubmitted: (_) => _submit(),
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
                        : const Text('Prijava'),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ili', style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google login
                  OutlinedButton.icon(
                    onPressed: _googleLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE85D04))),
                    label: const Text('Nastavi s Googleom', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Nemaš račun? Registriraj se', style: TextStyle(color: Color(0xFFE85D04))),
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
