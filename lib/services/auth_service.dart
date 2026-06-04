import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthException implements Exception {
  final int statusCode;
  final String message;

  const AuthException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const _tokenKey = 'sk_access_token';
  static const _expiresAtKey = 'sk_expires_at';
  static const _userNameKey = 'sk_user_name';

  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://sibkredit.dev.redramka.ru/rest/auth';

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['success'] != true) {
      throw AuthException(
        response.statusCode,
        json['error'] as String? ?? 'Неизвестная ошибка',
      );
    }

    return json['data'] as Map<String, dynamic>;
  }

  Future<({String tempToken, int expiresIn})> login(
    String phone,
    String password,
  ) async {
    final normalizedPhone =
        phone.replaceAll(RegExp(r'[^\d]'), '');
    final last10 = normalizedPhone.length > 10
        ? normalizedPhone.substring(normalizedPhone.length - 10)
        : normalizedPhone;

    final data = await _post('/login', {
      'phone': last10,
      'password': password,
    });

    return (
      tempToken: data['temp_token'] as String,
      expiresIn: data['expires_in'] as int,
    );
  }

  Future<UserModel> confirm(String tempToken, String code) async {
    final data = await _post('/confirm', {
      'temp_token': tempToken,
      'code': code,
    });

    await _storage.write(key: _tokenKey, value: data['access_token'] as String);
    await _storage.write(key: _expiresAtKey, value: data['expires_at'] as String);

    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.write(key: _userNameKey, value: user.displayName);

    return user;
  }

  Future<bool> isSessionValid() async {
    final token = await _storage.read(key: _tokenKey);
    final expiresAt = await _storage.read(key: _expiresAtKey);

    if (token == null || expiresAt == null) return false;

    return DateTime.parse(expiresAt).isAfter(DateTime.now());
  }

  Future<String?> getStoredUserName() => _storage.read(key: _userNameKey);

  Future<String?> getStoredToken() => _storage.read(key: _tokenKey);

  Future<bool> verifyToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 401) {
        await _storage.delete(key: _tokenKey);
        await _storage.delete(key: _expiresAtKey);
        await _storage.delete(key: _userNameKey);
        return false;
      }
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: _tokenKey);

    if (token != null) {
      try {
        await _post('/logout', {}, token: token);
      } catch (_) {}
    }

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _userNameKey);
  }
}
