import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_storage_web.dart' if (dart.library.io) 'auth_storage_stub.dart' as web;

class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage(this._storage);

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      web.saveToken(token);
    } else {
      await _storage.write(key: 'auth_token', value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return web.getToken();
    }
    return _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      web.deleteToken();
    } else {
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<bool> hasToken() async => (await getToken()) != null;
}
