import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService I = AuthService._();

  static const String _tokenKey = 'auth_token';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_tokenKey) ?? '').isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> fetchMe() async {
    final token = await getToken();
    final res = await ApiClient.I.dio.get(
      '/users/me',
      options: Options(headers: token != null && token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null),
    );
    return (res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateMe({required String name}) async {
    final token = await getToken();
    final res = await ApiClient.I.dio.patch(
      '/users/me',
      data: {'name': name},
      options: Options(headers: token != null && token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null),
    );
    return (res.data as Map<String, dynamic>);
  }

  Future<void> signup({required String name, required String email, required String password}) async {
    await ApiClient.I.dio.post('/auth/signup', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> login({required String email, required String password}) async {
    final Response res = await ApiClient.I.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final String token = (res.data['token'] ?? '').toString();
    if (token.isEmpty) {
      throw DioException(requestOptions: RequestOptions(path: '/auth/login'), error: 'Token missing');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}


