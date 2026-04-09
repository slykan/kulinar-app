import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/api/api_client.dart';

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
    debugPrint('GOOGLE CALLBACK TOKEN: "$token"');
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token je null ili prazan!'), backgroundColor: Colors.red, duration: Duration(seconds: 10)),
        );
      }
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) context.go('/login');
      return;
    }

    // Debug — prikaži što smo primili
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token primljen: "${token.substring(0, token.length > 30 ? 30 : token.length)}"'), duration: const Duration(seconds: 8)),
      );
    }
    await Future.delayed(const Duration(seconds: 1));

    // Spremi token
    final storage = ref.read(authStorageProvider);
    await storage.saveToken(token);

    // Dohvati user podatke — direktno s tokenom u headeru (ne kroz interceptor)
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.dio.get(
        '/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final user = response.data as Map<String, dynamic>;
      ref.read(authProvider.notifier).updateUser(user);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login error: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 10)),
        );
        await Future.delayed(const Duration(seconds: 10));
        context.go('/login');
      }
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
