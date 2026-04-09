import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/api/api_client.dart';

class GoogleCallbackScreen extends ConsumerStatefulWidget {
  final String? token;
  final String? user;
  final String? error;
  const GoogleCallbackScreen({super.key, this.token, this.user, this.error});

  @override
  ConsumerState<GoogleCallbackScreen> createState() => _GoogleCallbackScreenState();
}

class _GoogleCallbackScreenState extends ConsumerState<GoogleCallbackScreen> {
  String? _errorMsg;
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    // Prikaži error ako postoji
    if (widget.error != null) {
      setState(() => _errorMsg = widget.error);
      await Future.delayed(const Duration(seconds: 8));
      if (mounted) context.go('/login');
      return;
    }

    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() => _errorMsg = 'Token nije primljen.');
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) context.go('/login');
      return;
    }

    // Spremi token
    final storage = ref.read(authStorageProvider);
    await storage.saveToken(token);

    // User podaci dolaze direktno iz URL-a — ne trebamo zvati /me
    try {
      Map<String, dynamic>? userData;
      if (widget.user != null) {
        userData = json.decode(widget.user!) as Map<String, dynamic>;
      }
      if (userData != null) {
        ref.read(authProvider.notifier).updateUser(userData);
        if (mounted) context.go('/');
      } else {
        // Fallback — pokušaj /me
        final client = ref.read(apiClientProvider);
        final response = await client.dio.get(
          '/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        ref.read(authProvider.notifier).updateUser(response.data as Map<String, dynamic>);
        if (mounted) context.go('/');
      }
    } catch (e) {
      setState(() => _errorMsg = e.toString());
      await Future.delayed(const Duration(seconds: 6));
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818),
      body: Center(
        child: _errorMsg != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Greška: $_errorMsg', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                ),
              )
            : const Column(
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
