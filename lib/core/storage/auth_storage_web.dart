// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void saveToken(String token) {
  html.window.localStorage['kulinar_token'] = token;
}

String? getToken() {
  return html.window.localStorage['kulinar_token'];
}

void deleteToken() {
  html.window.localStorage.remove('kulinar_token');
  html.window.localStorage.remove('kulinar_user');
}

void saveUser(String userJson) {
  html.window.localStorage['kulinar_user'] = userJson;
}

String? getUser() {
  return html.window.localStorage['kulinar_user'];
}
