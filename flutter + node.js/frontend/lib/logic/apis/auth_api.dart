import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthApi {
  final String baseUrl;

  /// For local development, use 'http://localhost:3000'
  const AuthApi({required this.baseUrl});

  Future<String> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pisync/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pisync/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
