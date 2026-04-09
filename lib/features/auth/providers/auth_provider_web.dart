// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

String? getLocalStorageToken() {
  return html.window.localStorage['kulinar_token'];
}

Map<String, dynamic>? getLocalStorageUser() {
  final raw = html.window.localStorage['kulinar_user'];
  if (raw == null) return null;
  try {
    return json.decode(raw) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

void clearLocalStorageAuth() {
  html.window.localStorage.remove('kulinar_token');
  html.window.localStorage.remove('kulinar_user');
}
