import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage(this._storage);

  Future<void> saveToken(String token) => _storage.write(key: 'auth_token', value: token);
  Future<String?> getToken() => _storage.read(key: 'auth_token');
  Future<void> deleteToken() => _storage.delete(key: 'auth_token');
  Future<bool> hasToken() async => (await _storage.read(key: 'auth_token')) != null;
}
