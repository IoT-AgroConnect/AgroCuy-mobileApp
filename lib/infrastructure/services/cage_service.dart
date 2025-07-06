import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrocuy/features/animals/data/models/jaula_model.dart';
import 'base_service.dart';
import 'session_service.dart';

class CageService extends BaseService {
  static final CageService _instance = CageService._internal();
  final SessionService _sessionService = SessionService();

  factory CageService() {
    return _instance;
  }

  CageService._internal();

  String get cagesEndpoint => '$baseUrl/cages';

  /// Get the authorization headers with token
  Future<Map<String, String>> get _authHeaders async {
    // Ensure session is initialized
    await _sessionService.init();

    final token = _sessionService.getToken();
    print('DEBUG: Token length: ${token.length}');
    print(
        'DEBUG: Token (first 50 chars): ${token.length > 50 ? token.substring(0, 50) : token}');

    if (token.isNotEmpty) {
      final headers = getHeaders(token);
      print('DEBUG: Headers with token: $headers');
      return headers;
    } else {
      print('DEBUG: No token found, using basic headers');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  /// Get all cages
  Future<List<JaulaModel>> getAllCages() async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse(cagesEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('DEBUG CageService: Raw backend response: $jsonList');

        final mappedCages = jsonList.map((json) {
          print('DEBUG CageService: Original cage JSON: $json');
          final mapped = _mapCageToJaula(json);
          print('DEBUG CageService: Mapped cage JSON: $mapped');
          return JaulaModel.fromJson(mapped);
        }).toList();

        print(
            'DEBUG CageService: Successfully mapped ${mappedCages.length} cages');
        return mappedCages;
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception(
            '403: Acceso denegado. No tienes permisos para ver las jaulas.');
      } else if (response.statusCode == 404) {
        throw Exception('404: Endpoint no encontrado.');
      } else if (response.statusCode == 500) {
        throw Exception('500: Error interno del servidor.');
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Error de conexión: Verifica tu conexión a internet y que el servidor esté disponible.');
      }
      throw Exception('Error fetching cages: $e');
    }
  }

  /// Get cage by ID
  Future<JaulaModel?> getCageById(int cageId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$cagesEndpoint/$cageId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return JaulaModel.fromJson(_mapCageToJaula(json));
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('403: Acceso denegado.');
      } else {
        throw Exception('Failed to load cage: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cage: $e');
    }
  }

  /// Create a new cage
  Future<JaulaModel?> createCage(CreateCageRequest request) async {
    try {
      print('DEBUG: Creating cage with request: ${request.toJson()}');

      final headers = await _authHeaders;
      print('DEBUG: Using headers: $headers');

      final response = await http.post(
        Uri.parse(cagesEndpoint),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print('DEBUG: Create cage response status: ${response.statusCode}');
      print('DEBUG: Create cage response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return JaulaModel.fromJson(_mapCageToJaula(json));
      } else if (response.statusCode == 400) {
        throw Exception('400: Datos inválidos para crear la jaula.');
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('403: Acceso denegado.');
      } else {
        throw Exception('Failed to create cage: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error creating cage: $e');
      throw Exception('Error creating cage: $e');
    }
  }

  /// Update an existing cage
  Future<JaulaModel?> updateCage(int cageId, UpdateCageRequest request) async {
    try {
      final headers = await _authHeaders;
      final response = await http.put(
        Uri.parse('$cagesEndpoint/$cageId'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return JaulaModel.fromJson(_mapCageToJaula(json));
      } else if (response.statusCode == 400) {
        throw Exception('400: Datos inválidos para actualizar la jaula.');
      } else if (response.statusCode == 404) {
        throw Exception('404: Jaula no encontrada.');
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('403: Acceso denegado.');
      } else {
        throw Exception('Failed to update cage: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating cage: $e');
    }
  }

  /// Delete a cage
  Future<bool> deleteCage(int cageId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.delete(
        Uri.parse('$cagesEndpoint/$cageId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('404: Jaula no encontrada.');
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('403: Acceso denegado.');
      } else {
        throw Exception('Failed to delete cage: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting cage: $e');
    }
  }

  /// Get animals in a specific cage
  Future<List<AnimalModel>> getAnimalsByCageId(int cageId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$cagesEndpoint/$cageId/animals'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AnimalModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // Return empty list if cage not found
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('403: Acceso denegado.');
      } else {
        throw Exception('Failed to load animals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching animals by cage: $e');
    }
  }

  /// Convenience method for getting cages with better error handling
  Future<List<JaulaModel>> getCagesWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await getAllCages();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    return [];
  }

  /// Helper method to map backend cage response to JaulaModel format
  Map<String, dynamic> _mapCageToJaula(Map<String, dynamic> cageJson) {
    return {
      'id': cageJson['id'] ?? 0,
      'nombre': cageJson['name'] ?? cageJson['nombre'] ?? '',
      'descripcion': cageJson['observations'] ??
          cageJson['description'] ??
          cageJson['descripcion'] ??
          '',
      'capacidadMaxima': cageJson['size'] ??
          cageJson['maxCapacity'] ??
          cageJson['capacidadMaxima'] ??
          0,
      'fechaCreacion': cageJson['createdDate'] ??
          cageJson['fechaCreacion'] ??
          DateTime.now().toIso8601String(),
      'activa': cageJson['active'] ?? cageJson['activa'] ?? true,
    };
  }

  /// Debug method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    await _sessionService.init();
    final token = _sessionService.getToken();
    print('DEBUG: isAuthenticated check - token length: ${token.length}');
    print(
        'DEBUG: isAuthenticated check - token: ${token.isEmpty ? 'EMPTY' : token.substring(0, 20)}...');
    return token.isNotEmpty;
  }

  /// Debug method to get current token (for debugging only)
  String getCurrentToken() {
    return _sessionService.getToken();
  }
}

/// Create cage request model
class CreateCageRequest {
  final String name;
  final String observations;
  final int size;
  final int breederId;

  CreateCageRequest({
    required this.name,
    required this.observations,
    required this.size,
    required this.breederId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'observations': observations,
      'size': size,
      'breederId': breederId,
    };
  }
}

/// Update cage request model
class UpdateCageRequest {
  final String name;
  final String observations;
  final int size;

  UpdateCageRequest({
    required this.name,
    required this.observations,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'observations': observations,
      'size': size,
    };
  }
}

/// Animal model for animals in cages
class AnimalModel {
  final int id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final double weight;
  final String color;
  final String status;
  final int cageId;
  final DateTime entryDate;
  final String? observations;

  AnimalModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.color,
    required this.status,
    required this.cageId,
    required this.entryDate,
    this.observations,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? json['sexo'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : DateTime.now(),
      weight: (json['weight'] ?? 0).toDouble(),
      color: json['color'] ?? '',
      status: json['status'] ?? json['estado'] ?? '',
      cageId: json['cageId'] ?? json['jaulaId'] ?? 0,
      entryDate: json['entryDate'] != null
          ? DateTime.parse(json['entryDate'])
          : DateTime.now(),
      observations: json['observations'] ?? json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'color': color,
      'status': status,
      'cageId': cageId,
      'entryDate': entryDate.toIso8601String(),
      'observations': observations,
    };
  }
}
