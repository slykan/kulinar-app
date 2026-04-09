import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/api/auth_service.dart';

class GoogleCallbackScreen extends ConsumerStatefulWidget {
  final String? token;
  const GoogleCallbackScreen({super.key, this.token});

  @override
  ConsumerState<GoogleCallbackScreen> createState() => _GoogleCallbackScreenState();
}

class _GoogleCallbackScreenState extends ConsumerState<GoogleCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      context.go('/login');
      return;
    }

    // Spremi token
    final storage = ref.read(authStorageProvider);
    await storage.saveToken(token);

    // Dohvati user podatke
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.me();
      ref.read(authProvider.notifier).updateUser(user);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF181818),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE85D04)),
            SizedBox(height: 16),
            Text('Prijava u tijeku...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
