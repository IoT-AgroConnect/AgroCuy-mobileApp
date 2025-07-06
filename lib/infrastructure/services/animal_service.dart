import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'session_service.dart';

// Breed enum matching backend
enum Breed {
  ANDINA,
  INTI,
  PERU,
  KURI;

  // Convert to string for API
  String get value => name;

  // Get display name for UI
  String get displayName {
    switch (this) {
      case Breed.ANDINA:
        return 'Andina';
      case Breed.INTI:
        return 'Inti';
      case Breed.PERU:
        return 'Perú';
      case Breed.KURI:
        return 'Kuri';
    }
  }

  // Create from string
  static Breed fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ANDINA':
        return Breed.ANDINA;
      case 'INTI':
        return Breed.INTI;
      case 'PERU':
        return Breed.PERU;
      case 'KURI':
        return Breed.KURI;
      default:
        return Breed.ANDINA; // Default fallback
    }
  }
}

class AnimalModel {
  final int id;
  final String name;
  final Breed breed;
  final bool gender; // true = male, false = female
  final DateTime birthdate;
  final double weight;
  final bool isSick;
  final String? observations;
  final int cageId;

  AnimalModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.birthdate,
    required this.weight,
    required this.isSick,
    this.observations,
    required this.cageId,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      breed: Breed.fromString(json['breed'] ?? 'ANDINA'),
      gender: json['gender'] ?? true,
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : DateTime.now(),
      weight: (json['weight'] ?? 0).toDouble(),
      isSick: json['isSick'] ?? false,
      observations: json['observations'],
      cageId: json['cageId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed.value,
      'gender': gender,
      'birthdate':
          birthdate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'weight': weight,
      'isSick': isSick,
      'observations': observations,
      'cageId': cageId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'breed': breed.value,
      'gender': gender,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'weight': weight,
      'isSick': isSick,
      'observations': observations,
      'cageId': cageId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'breed': breed.value,
      'gender': gender,
      'birthdate': birthdate.toIso8601String().split('T')[0],
      'weight': weight,
      'isSick': isSick,
      'observations': observations,
      'cageId': cageId,
    };
  }

  // Utility getters for UI
  String get sexo => gender ? 'macho' : 'hembra';
  String get estado => isSick ? 'enfermo' : 'sano';
  String get color =>
      breed.displayName; // Using breed display name as color for now
  DateTime get fechaNacimiento => birthdate;
  DateTime get fechaIngreso => birthdate; // Assuming same as birthdate for now
  double get peso => weight;
  String? get observaciones => observations;

  String get edadFormateada {
    final now = DateTime.now();
    final difference = now.difference(birthdate);
    final days = difference.inDays;

    if (days < 30) {
      return '$days días';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      return '$years ${years == 1 ? 'año' : 'años'}${remainingMonths > 0 ? ' $remainingMonths ${remainingMonths == 1 ? 'mes' : 'meses'}' : ''}';
    }
  }
}

class AnimalService extends BaseService {
  static final AnimalService _instance = AnimalService._internal();
  factory AnimalService() => _instance;
  AnimalService._internal() {
    print('🐹 DEBUG ANIMAL: AnimalService initialized');
    print('🌐 DEBUG ANIMAL: Base URL configured: $baseUrl');
    print('🔧 DEBUG ANIMAL: Service ready for animal requests');
  }

  final SessionService _sessionService = SessionService();

  String get animalsEndpoint => '$baseUrl/animals';

  /// Get the authorization headers with token
  Future<Map<String, String>> get _authHeaders async {
    // Ensure session is initialized
    await _sessionService.init();

    final token = _sessionService.getToken();
    print('🔑 DEBUG ANIMAL: Token length: ${token.length}');
    print(
        '🔑 DEBUG ANIMAL: Token (first 50 chars): ${token.length > 50 ? token.substring(0, 50) : token}...');

    if (token.isNotEmpty) {
      final headers = getHeaders(token);
      print('📋 DEBUG ANIMAL: Headers with token: $headers');
      return headers;
    } else {
      print('⚠️ DEBUG ANIMAL: No token found, using basic headers');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  /// Verifica si el usuario está autenticado
  bool isAuthenticated() {
    final token = _sessionService.getToken();
    print(
        '🔐 DEBUG ANIMAL: isAuthenticated check - token length: ${token.length}');
    return token.isNotEmpty;
  }

  /// Obtiene todos los animales
  Future<List<AnimalModel>> getAllAnimals() async {
    print('🐹 DEBUG ANIMAL: Starting getAllAnimals request...');

    if (!isAuthenticated()) {
      print('❌ DEBUG ANIMAL: User not authenticated');
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      print('🌐 DEBUG ANIMAL: Making request to $animalsEndpoint');
      final headers = await _authHeaders;

      final response = await http.get(
        Uri.parse(animalsEndpoint),
        headers: headers,
      );

      print('📡 DEBUG ANIMAL: Response received');
      print('🔢 DEBUG ANIMAL: Response status: ${response.statusCode}');
      print('📄 DEBUG ANIMAL: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(
            '✅ DEBUG ANIMAL: Successfully parsed ${data.length} animals from response');
        return data.map((item) => AnimalModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        print('🔒 DEBUG ANIMAL: Unauthorized - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '❌ DEBUG ANIMAL: Request failed with status: ${response.statusCode}');
        print('💬 DEBUG ANIMAL: Error response: ${response.body}');
        throw Exception('Error al obtener animales: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 DEBUG ANIMAL: Exception in getAllAnimals: $e');
      print('🔍 DEBUG ANIMAL: Exception type: ${e.runtimeType}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene un animal por ID
  Future<AnimalModel?> getAnimalById(int animalId) async {
    print('🐹 DEBUG ANIMAL: Starting getAnimalById request for ID: $animalId');

    if (!isAuthenticated()) {
      print('❌ DEBUG ANIMAL: User not authenticated');
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final url = '$animalsEndpoint/$animalId';
      print('🌐 DEBUG ANIMAL: Making request to $url');

      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📡 DEBUG ANIMAL: getAnimalById response received');
      print('🔢 DEBUG ANIMAL: Response status: ${response.statusCode}');
      print('📄 DEBUG ANIMAL: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ DEBUG ANIMAL: Successfully retrieved animal data');
        return AnimalModel.fromJson(data);
      } else if (response.statusCode == 404) {
        print('🔍 DEBUG ANIMAL: Animal not found with ID: $animalId');
        return null; // Animal no encontrado
      } else if (response.statusCode == 401) {
        print('🔒 DEBUG ANIMAL: Unauthorized - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '❌ DEBUG ANIMAL: Request failed with status: ${response.statusCode}');
        print('💬 DEBUG ANIMAL: Error response: ${response.body}');
        throw Exception('Error al obtener animal: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 DEBUG ANIMAL: Exception in getAnimalById: $e');
      print('🔍 DEBUG ANIMAL: Exception type: ${e.runtimeType}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene animales por ID de jaula (filtrado desde getAllAnimals)
  Future<List<AnimalModel>> getAnimalsByCageId(int cageId) async {
    print('🏠 DEBUG ANIMAL: Starting getAnimalsByCageId for cage: $cageId');

    try {
      // First try the endpoint /cages/{cageId}/animals
      try {
        print('🔄 DEBUG ANIMAL: Trying direct endpoint for cage animals');
        final url = '$baseUrl/cages/$cageId/animals';
        print('🌐 DEBUG ANIMAL: Direct endpoint URL: $url');

        final headers = await _authHeaders;
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );

        print('📡 DEBUG ANIMAL: Direct endpoint response received');
        print('🔢 DEBUG ANIMAL: Response status: ${response.statusCode}');
        print('📄 DEBUG ANIMAL: Response body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          print(
              '✅ DEBUG ANIMAL: Direct endpoint returned ${data.length} animals for cage $cageId');
          return data.map((item) => AnimalModel.fromJson(item)).toList();
        }
      } catch (e) {
        print('⚠️ DEBUG ANIMAL: Direct endpoint failed: $e');
      }

      // Fallback: get all animals and filter
      print('🔄 DEBUG ANIMAL: Falling back to getAllAnimals and filtering');
      final allAnimals = await getAllAnimals();
      print('📊 DEBUG ANIMAL: Total animals fetched: ${allAnimals.length}');
      final filteredAnimals =
          allAnimals.where((animal) => animal.cageId == cageId).toList();
      print(
          '✅ DEBUG ANIMAL: Animals for cage $cageId: ${filteredAnimals.length}');
      return filteredAnimals;
    } catch (e) {
      print('🚨 DEBUG ANIMAL: Exception in getAnimalsByCageId: $e');
      print('🔍 DEBUG ANIMAL: Exception type: ${e.runtimeType}');
      throw Exception('Error al obtener animales de la jaula: ${e.toString()}');
    }
  }

  /// Crea un nuevo animal
  Future<AnimalModel> createAnimal(AnimalModel animal) async {
    print('➕ DEBUG ANIMAL: Starting createAnimal...');
    print('🐹 DEBUG ANIMAL: Animal name: ${animal.name}');
    print('🏠 DEBUG ANIMAL: Cage ID: ${animal.cageId}');

    if (!isAuthenticated()) {
      print('❌ DEBUG ANIMAL: User not authenticated');
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final url = animalsEndpoint;
      print('🌐 DEBUG ANIMAL: Making POST request to $url');

      final createData = animal.toCreateJson();
      print('📦 DEBUG ANIMAL: Request body: ${json.encode(createData)}');

      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(createData),
      );

      print('📡 DEBUG ANIMAL: createAnimal response received');
      print('🔢 DEBUG ANIMAL: Response status: ${response.statusCode}');
      print('📄 DEBUG ANIMAL: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ DEBUG ANIMAL: Animal created successfully');
        return AnimalModel.fromJson(data);
      } else if (response.statusCode == 401) {
        print('🔒 DEBUG ANIMAL: Unauthorized - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '❌ DEBUG ANIMAL: Create failed with status: ${response.statusCode}');
        print('💬 DEBUG ANIMAL: Error response: ${response.body}');
        throw Exception('Error al crear animal: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 DEBUG ANIMAL: Exception in createAnimal: $e');
      print('🔍 DEBUG ANIMAL: Exception type: ${e.runtimeType}');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualiza un animal existente
  Future<AnimalModel> updateAnimal(int animalId, AnimalModel animal) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final headers = await _authHeaders;
      final response = await http.put(
        Uri.parse('$animalsEndpoint/$animalId'),
        headers: headers,
        body: json.encode(animal.toUpdateJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AnimalModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Animal no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al actualizar animal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Elimina un animal
  Future<bool> deleteAnimal(int animalId) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final headers = await _authHeaders;
      final response = await http.delete(
        Uri.parse('$animalsEndpoint/$animalId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Animal no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al eliminar animal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Método con reintentos para obtener animales por jaula
  Future<List<AnimalModel>> getAnimalsByCageIdWithRetry(int cageId,
      {int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await getAnimalsByCageId(cageId);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(
              Duration(seconds: attempts * 2)); // Backoff exponencial
        }
      }
    }

    throw lastException ?? Exception('Error desconocido al obtener animales');
  }

  /// Método con reintentos para obtener todos los animales
  Future<List<AnimalModel>> getAllAnimalsWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await getAllAnimals();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(
              Duration(seconds: attempts * 2)); // Backoff exponencial
        }
      }
    }

    throw lastException ?? Exception('Error desconocido al obtener animales');
  }
}
