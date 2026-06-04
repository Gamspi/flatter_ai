import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/loan_model.dart';
import '../models/deposit_model.dart';
import '../services/auth_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ArchiveService {
  static const _tokenKey = 'sk_access_token';
  final _storage = const FlutterSecureStorage();

  String get _host => dotenv.env['API_HOST'] ?? 'https://sibkredit.dev.redramka.ru';

  Future<({List<LoanModel> loans, List<DepositModel> deposits})> getArchive() async {
    final token = await _storage.read(key: _tokenKey);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$_host/rest/personal/archive'),
      headers: headers,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      throw AuthException(401, json['error'] as String);
    }

    if (json['success'] != true) {
      throw ApiException(response.statusCode, json['error'] as String);
    }

    final data = json['data'] as Map<String, dynamic>;

    final loans = (data['loans'] as List<dynamic>)
        .map((e) => LoanModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final deposits = (data['deposits'] as List<dynamic>)
        .map((e) => DepositModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return (loans: loans, deposits: deposits);
  }
}
