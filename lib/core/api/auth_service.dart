import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String turnstileToken,
  }) async {
    final response = await _client.dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'cf_turnstile_response': turnstileToken,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String turnstileToken,
  }) async {
    final response = await _client.dio.post('/login', data: {
      'email': email,
      'password': password,
      'cf_turnstile_response': turnstileToken,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<String> getGoogleAuthUrl({bool mobile = false}) async {
    final response = await _client.dio.get(
      '/auth/google',
      queryParameters: mobile ? {'mobile': '1'} : null,
    );
    return response.data['url'] as String;
  }

  Future<Map<String, dynamic>> googleCallback(String code) async {
    final response = await _client.dio.get('/auth/google/callback', queryParameters: {'code': code});
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _client.dio.post('/logout');
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _client.dio.get('/me');
    return response.data as Map<String, dynamic>;
  }
}
