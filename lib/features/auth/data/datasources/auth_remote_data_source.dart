import 'dart:convert';
import 'package:http/http.dart' as http;
// Base service import
import 'package:agrocuy/infrastructure/services/base_service.dart';

class AuthRemoteDataSource extends BaseService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": email, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login fallido');
    }
  }

  Future<Map<String, dynamic>> getUserData(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: getHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos de usuario');
    }
  }

  Future<Map<String, dynamic>> getProfileByRole(String token, String role) async {
    final url = role == 'ROLE_BREEDER'
        ? '$baseUrl/breeders'
        : '$baseUrl/advisors';

    final response = await http.get(
      Uri.parse(url),
      headers: getHeaders(token),
    );

    if (response.statusCode == 200) {
      return {'list': jsonDecode(response.body)};
    } else {
      throw Exception('Error al obtener perfil');
    }
  }

  Future<bool> registerUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "password": password,
        "roles": [role],
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> signInUser({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}

