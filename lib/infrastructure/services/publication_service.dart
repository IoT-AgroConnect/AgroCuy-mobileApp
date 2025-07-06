import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'session_service.dart';

class PublicationService extends BaseService {
  static final PublicationService _instance = PublicationService._internal();
  final SessionService _sessionService = SessionService();

  factory PublicationService() {
    return _instance;
  }

  PublicationService._internal();

  String get publicationsEndpoint => '$baseUrl/publications';

  /// Get the authorization headers with token
  Map<String, String> get _authHeaders {
    final token = _sessionService.getToken();
    if (token.isNotEmpty) {
      return getHeaders(token);
    } else {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  /// Get all publications
  Future<List<Publication>> getAllPublications() async {
    try {
      final response = await http.get(
        Uri.parse(publicationsEndpoint),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Publication.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception(
            '403: Acceso denegado. No tienes permisos para ver las publicaciones.');
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
      throw Exception('Error fetching publications: $e');
    }
  }

  /// Get publication by ID
  Future<Publication?> getPublicationById(int publicationId) async {
    try {
      final response = await http.get(
        Uri.parse('$publicationsEndpoint/$publicationId'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Publication.fromJson(json);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load publication: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching publication: $e');
    }
  }

  /// Create a new publication
  Future<Publication?> createPublication(
      CreatePublicationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(publicationsEndpoint),
        headers: _authHeaders,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Publication.fromJson(json);
      } else {
        throw Exception('Failed to create publication: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating publication: $e');
    }
  }

  /// Update an existing publication
  Future<Publication?> updatePublication(
      int publicationId, UpdatePublicationRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('$publicationsEndpoint/$publicationId'),
        headers: _authHeaders,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Publication.fromJson(json);
      } else {
        throw Exception('Failed to update publication: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating publication: $e');
    }
  }

  /// Delete a publication
  Future<bool> deletePublication(int publicationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$publicationsEndpoint/$publicationId'),
        headers: _authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting publication: $e');
    }
  }

  /// Convenience method for getting publications with better error handling
  Future<List<Publication>> getPublicationsWithRetry(
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await getAllPublications();
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

  /// Debug method to check if user is authenticated
  bool isAuthenticated() {
    final token = _sessionService.getToken();
    return token.isNotEmpty;
  }

  /// Debug method to get current token (for debugging only)
  String getCurrentToken() {
    return _sessionService.getToken();
  }
}

/// Publication model
class Publication {
  final int id;
  final String title;
  final String description;
  final String image;
  final DateTime date;
  final int advisorId;

  Publication({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.advisorId,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      advisorId: json['advisorId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'date': date.toIso8601String(),
      'advisorId': advisorId,
    };
  }
}

/// Create publication request model
class CreatePublicationRequest {
  final String title;
  final String description;
  final String image;
  final int advisorId;

  CreatePublicationRequest({
    required this.title,
    required this.description,
    required this.image,
    required this.advisorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'advisorId': advisorId,
    };
  }
}

/// Update publication request model
class UpdatePublicationRequest {
  final String title;
  final String description;
  final String image;

  UpdatePublicationRequest({
    required this.title,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
    };
  }
}
