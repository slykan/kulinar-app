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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> init() async {
    final storage = ref.read(authStorageProvider);
    final hasToken = await storage.hasToken();
    if (!hasToken) return;

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.me();
      state = state.copyWith(user: user);
    } catch (_) {
      await ref.read(authStorageProvider).deleteToken();
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
      await ref.read(authStorageProvider).saveToken(result['token']);
      state = state.copyWith(user: result['user'], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      await ref.read(authStorageProvider).saveToken(result['token']);
      state = state.copyWith(user: result['user'], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
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
