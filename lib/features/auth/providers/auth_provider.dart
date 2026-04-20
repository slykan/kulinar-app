import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/storage/auth_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((_) => const FlutterSecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthStorage(storage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthService(client);
});

class AuthState {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

String _parseError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        return (first is List && first.isNotEmpty) ? first.first.toString() : first.toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    if (e.response?.statusCode == 422) return 'Pogrešni podaci. Provjeri email i lozinku.';
    if (e.response?.statusCode == 401) return 'Pogrešan email ili lozinka.';
  }
  return 'Greška. Pokušaj ponovo.';
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> init() async {
    final storage = ref.read(authStorageProvider);
    final hasToken = await storage.hasToken();
    if (!hasToken) return;

    // Prvo pokušaj učitati usera iz localStoragea (bez mrežnog poziva)
    final cachedUser = await storage.getUser();
    if (cachedUser != null) {
      state = state.copyWith(user: cachedUser);
      return;
    }

    // Fallback: pozovi /me (radi na mobileu, može failati na webu)
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.me();
      await storage.saveUser(user);
      state = state.copyWith(user: user);
    } catch (_) {
      await storage.deleteToken();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String turnstileToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(authServiceProvider).login(
        email: email,
        password: password,
        turnstileToken: turnstileToken,
      );
      final storage = ref.read(authStorageProvider);
      await storage.saveToken(result['token']);
      await storage.saveUser(result['user'] as Map<String, dynamic>);
      state = state.copyWith(user: result['user'], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String turnstileToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(authServiceProvider).register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        turnstileToken: turnstileToken,
      );
      final storage = ref.read(authStorageProvider);
      await storage.saveToken(result['token']);
      await storage.saveUser(result['user'] as Map<String, dynamic>);
      state = state.copyWith(user: result['user'], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  void updateUser(Map<String, dynamic> user) {
    state = state.copyWith(user: user);
    ref.read(authStorageProvider).saveUser(user);
  }

  void clearUser() {
    state = const AuthState();
  }

  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();
    } catch (_) {}
    await ref.read(authStorageProvider).deleteToken();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
