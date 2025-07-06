import 'dart:convert';
import 'package:http/http.dart' as http;
// Base service import
import 'package:agrocuy/infrastructure/services/base_service.dart';

class AuthRemoteDataSource extends BaseService {
  AuthRemoteDataSource() {
    print('🚀 DEBUG AUTH: AuthRemoteDataSource initialized');
    print('🌐 DEBUG AUTH: Base URL configured: $baseUrl');
    print('🔧 DEBUG AUTH: Service ready for authentication requests');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/authentication/sign-in';
    final requestBody = {"username": email, "password": password};

    print('🔐 DEBUG AUTH: Starting login process...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('📧 DEBUG AUTH: Email: $email');
    print('📦 DEBUG AUTH: Request body: ${jsonEncode(requestBody)}');
    print('🔗 DEBUG AUTH: Base URL: $baseUrl');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📡 DEBUG AUTH: Response received');
      print('🔢 DEBUG AUTH: Status code: ${response.statusCode}');
      print('📋 DEBUG AUTH: Response headers: ${response.headers}');
      print('📄 DEBUG AUTH: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ DEBUG AUTH: Login successful');
        print(
            '🔑 DEBUG AUTH: Token received: ${responseData['token']?.toString().substring(0, 50)}...');
        return responseData;
      } else {
        print('❌ DEBUG AUTH: Login failed with status: ${response.statusCode}');
        print('💬 DEBUG AUTH: Error response: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception during login: $e');
      print('🔍 DEBUG AUTH: Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserData(String token, int userId) async {
    final url = '$baseUrl/users/$userId';
    final headers = getHeaders(token);

    print('👤 DEBUG AUTH: Getting user data...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('🆔 DEBUG AUTH: User ID: $userId');
    print(
        '🔑 DEBUG AUTH: Token (first 50 chars): ${token.substring(0, 50)}...');
    print('📋 DEBUG AUTH: Request headers: $headers');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📡 DEBUG AUTH: User data response received');
      print('🔢 DEBUG AUTH: Status code: ${response.statusCode}');
      print('📄 DEBUG AUTH: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        print('✅ DEBUG AUTH: User data retrieved successfully');
        print('👤 DEBUG AUTH: Username: ${userData['username']}');
        print('🎭 DEBUG AUTH: Roles: ${userData['roles']}');
        return userData;
      } else {
        print(
            '❌ DEBUG AUTH: Failed to get user data. Status: ${response.statusCode}');
        print('💬 DEBUG AUTH: Error response: ${response.body}');
        throw Exception(
            'HTTP ${response.statusCode}: Error al obtener datos de usuario - ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception getting user data: $e');
      print('🔍 DEBUG AUTH: Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfileByRole(
      String token, String role) async {
    final url =
        role == 'ROLE_BREEDER' ? '$baseUrl/breeders' : '$baseUrl/advisors';
    final headers = getHeaders(token);

    print('👥 DEBUG AUTH: Getting profile by role...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('🎭 DEBUG AUTH: Role: $role');
    print(
        '🔑 DEBUG AUTH: Token (first 50 chars): ${token.substring(0, 50)}...');
    print('📋 DEBUG AUTH: Request headers: $headers');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📡 DEBUG AUTH: Profile response received');
      print('🔢 DEBUG AUTH: Status code: ${response.statusCode}');
      print('📄 DEBUG AUTH: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final profileList = jsonDecode(response.body);
        print('✅ DEBUG AUTH: Profile data retrieved successfully');
        print('📊 DEBUG AUTH: Number of profiles found: ${profileList.length}');
        return {'list': profileList};
      } else {
        print(
            '❌ DEBUG AUTH: Failed to get profile. Status: ${response.statusCode}');
        print('💬 DEBUG AUTH: Error response: ${response.body}');
        throw Exception(
            'HTTP ${response.statusCode}: Error al obtener perfil - ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception getting profile: $e');
      print('🔍 DEBUG AUTH: Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<bool> registerUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final url = '$baseUrl/authentication/sign-up';
    final requestBody = {
      "username": username,
      "password": password,
      "roles": [role],
    };

    print('📝 DEBUG AUTH: Starting user registration...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('📧 DEBUG AUTH: Username: $username');
    print('🎭 DEBUG AUTH: Role: $role');
    print('📦 DEBUG AUTH: Request body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📡 DEBUG AUTH: Registration response received');
      print('🔢 DEBUG AUTH: Status code: ${response.statusCode}');
      print('📄 DEBUG AUTH: Response body: ${response.body}');

      final success = response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        print('✅ DEBUG AUTH: User registration successful');
      } else {
        print('❌ DEBUG AUTH: User registration failed');
        print('💬 DEBUG AUTH: Error response: ${response.body}');
      }

      return success;
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception during registration: $e');
      print('🔍 DEBUG AUTH: Exception type: ${e.runtimeType}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> signInUser({
    required String username,
    required String password,
  }) async {
    final url = '$baseUrl/authentication/sign-in';
    final requestBody = {"username": username, "password": password};

    print('🔐 DEBUG AUTH: Starting signInUser process...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('📧 DEBUG AUTH: Username: $username');
    print('📦 DEBUG AUTH: Request body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📡 DEBUG AUTH: SignInUser response received');
      print('🔢 DEBUG AUTH: Status code: ${response.statusCode}');
      print('📄 DEBUG AUTH: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ DEBUG AUTH: SignInUser successful');
        print(
            '🔑 DEBUG AUTH: Token received: ${responseData['token']?.toString().substring(0, 50)}...');
        return responseData;
      } else {
        print(
            '❌ DEBUG AUTH: SignInUser failed with status: ${response.statusCode}');
        print('💬 DEBUG AUTH: Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception during signInUser: $e');
      print('🔍 DEBUG AUTH: Exception type: ${e.runtimeType}');
      return null;
    }
  }

  Future<Map<String, dynamic>> getAdvisorById(
      String token, int advisorId) async {
    final url = '$baseUrl/advisors/$advisorId';
    final headers = {'Authorization': 'Bearer $token'};

    print('🧑‍🏫 DEBUG AUTH: Getting advisor by ID...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('🆔 DEBUG AUTH: Advisor ID: $advisorId');
    print(
        '🔑 DEBUG AUTH: Token (first 50 chars): ${token.substring(0, 50)}...');
    print('📋 DEBUG AUTH: Request headers: $headers');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📡 DEBUG AUTH: Advisor response received');
      print('🔢 DEBUG AUTH: Status code: ${response.statusCode}');
      print('📄 DEBUG AUTH: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final advisorData = jsonDecode(response.body);
        print('✅ DEBUG AUTH: Advisor data retrieved successfully');
        print(
            '👤 DEBUG AUTH: Advisor name: ${advisorData['fullname'] ?? 'N/A'}');
        return advisorData;
      } else {
        print(
            '❌ DEBUG AUTH: Failed to get advisor. Status: ${response.statusCode}');
        print('💬 DEBUG AUTH: Error response: ${response.body}');
        throw Exception(
            'HTTP ${response.statusCode}: Error al obtener asesor - ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception getting advisor: $e');
      print('🔍 DEBUG AUTH: Exception type: ${e.runtimeType}');
      rethrow;
    }
  }
}
