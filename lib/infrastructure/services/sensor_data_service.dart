import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'session_service.dart';

class SensorDataService extends BaseService {
  static final SensorDataService _instance = SensorDataService._internal();
  final SessionService _sessionService = SessionService();

  factory SensorDataService() {
    return _instance;
  }

  SensorDataService._internal();

  String get sensorDataEndpoint => '$baseUrl/iot/sensor-data';

  /// Get the authorization headers with token (async)
  Future<Map<String, String>> get _authHeaders async {
    print('[SensorDataService] Getting auth headers...');

    // Ensure session is initialized
    await _sessionService.init();

    final token = _sessionService.getToken();
    print(
        '[SensorDataService] Token retrieved: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Empty"}');

    if (token.isNotEmpty) {
      final headers = getHeaders(token);
      print('[SensorDataService] Auth headers: $headers');
      return headers;
    } else {
      print('[SensorDataService] No token available, using basic headers');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  /// Get all sensor data
  Future<List<SensorDataModel>> getAllSensorData() async {
    try {
      print('[SensorDataService] Getting all sensor data...');
      final headers = await _authHeaders;

      final response = await http.get(
        Uri.parse(sensorDataEndpoint),
        headers: headers,
      );

      print(
          '[SensorDataService] getAllSensorData response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print(
            '[SensorDataService] Retrieved ${jsonList.length} sensor data records');
        return jsonList.map((json) => SensorDataModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('[SensorDataService] 401 error - token expired or invalid');
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        print('[SensorDataService] 403 error - access denied');
        throw Exception(
            '403: Acceso denegado. No tienes permisos para ver los datos de sensores.');
      } else if (response.statusCode == 404) {
        print('[SensorDataService] 404 error - endpoint not found');
        throw Exception('404: Endpoint no encontrado.');
      } else if (response.statusCode == 500) {
        print('[SensorDataService] 500 error - server error');
        throw Exception('500: Error interno del servidor.');
      } else {
        print('[SensorDataService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('[SensorDataService] Exception in getAllSensorData: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Error de conexión: Verifica tu conexión a internet y que el servidor esté disponible.');
      }
      throw Exception('Error fetching sensor data: $e');
    }
  }

  /// Get sensor data by ID
  Future<SensorDataModel?> getSensorDataById(int sensorDataId) async {
    try {
      print('[SensorDataService] Getting sensor data by ID: $sensorDataId');
      final headers = await _authHeaders;

      final response = await http.get(
        Uri.parse('$sensorDataEndpoint/$sensorDataId'),
        headers: headers,
      );

      print(
          '[SensorDataService] getSensorDataById response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print(
            '[SensorDataService] Retrieved sensor data for ID: $sensorDataId');
        return SensorDataModel.fromJson(json);
      } else if (response.statusCode == 404) {
        print(
            '[SensorDataService] Sensor data not found for ID: $sensorDataId');
        return null;
      } else if (response.statusCode == 401) {
        print('[SensorDataService] 401 error - token expired or invalid');
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        print('[SensorDataService] 403 error - access denied');
        throw Exception('403: Acceso denegado.');
      } else {
        print('[SensorDataService] Unexpected error: ${response.statusCode}');
        throw Exception('Failed to load sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('[SensorDataService] Exception in getSensorDataById: $e');
      throw Exception('Error fetching sensor data: $e');
    }
  }

  /// Get sensor data by cage ID
  Future<List<SensorDataModel>> getSensorDataByCageId(int cageId) async {
    try {
      print('[SensorDataService] Getting sensor data for cage ID: $cageId');
      final headers = await _authHeaders;

      final response = await http.get(
        Uri.parse('$sensorDataEndpoint/by-cage/$cageId'),
        headers: headers,
      );

      print(
          '[SensorDataService] getSensorDataByCageId response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print(
            '[SensorDataService] Retrieved ${jsonList.length} sensor data records for cage $cageId');
        return jsonList.map((json) => SensorDataModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('[SensorDataService] No sensor data found for cage: $cageId');
        return []; // Return empty list if no sensor data found for cage
      } else if (response.statusCode == 401) {
        print('[SensorDataService] 401 error - token expired or invalid');
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        print('[SensorDataService] 403 error - access denied');
        throw Exception('403: Acceso denegado.');
      } else {
        print('[SensorDataService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Failed to load sensor data for cage: ${response.statusCode}');
      }
    } catch (e) {
      print('[SensorDataService] Exception in getSensorDataByCageId: $e');
      throw Exception('Error fetching sensor data by cage: $e');
    }
  }

  /// Create new sensor data
  Future<SensorDataModel?> createSensorData(
      CreateSensorDataRequest request) async {
    try {
      print(
          '[SensorDataService] Creating new sensor data for cage: ${request.cageId}');
      final headers = await _authHeaders;

      final response = await http.post(
        Uri.parse(sensorDataEndpoint),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print(
          '[SensorDataService] createSensorData response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('[SensorDataService] Successfully created sensor data');
        return SensorDataModel.fromJson(json);
      } else if (response.statusCode == 400) {
        print('[SensorDataService] 400 error - invalid data');
        throw Exception('400: Datos inválidos para crear el dato de sensor.');
      } else if (response.statusCode == 401) {
        print('[SensorDataService] 401 error - token expired or invalid');
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        print('[SensorDataService] 403 error - access denied');
        throw Exception('403: Acceso denegado.');
      } else {
        print('[SensorDataService] Unexpected error: ${response.statusCode}');
        throw Exception('Failed to create sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('[SensorDataService] Exception in createSensorData: $e');
      throw Exception('Error creating sensor data: $e');
    }
  }

  /// Update existing sensor data
  Future<SensorDataModel?> updateSensorData(
      int sensorDataId, UpdateSensorDataRequest request) async {
    try {
      print('[SensorDataService] Updating sensor data ID: $sensorDataId');
      final headers = await _authHeaders;

      final response = await http.put(
        Uri.parse('$sensorDataEndpoint/$sensorDataId'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print(
          '[SensorDataService] updateSensorData response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print(
            '[SensorDataService] Successfully updated sensor data ID: $sensorDataId');
        return SensorDataModel.fromJson(json);
      } else if (response.statusCode == 400) {
        print('[SensorDataService] 400 error - invalid data');
        throw Exception(
            '400: Datos inválidos para actualizar el dato de sensor.');
      } else if (response.statusCode == 404) {
        print('[SensorDataService] 404 error - sensor data not found');
        throw Exception('404: Dato de sensor no encontrado.');
      } else if (response.statusCode == 401) {
        print('[SensorDataService] 401 error - token expired or invalid');
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        print('[SensorDataService] 403 error - access denied');
        throw Exception('403: Acceso denegado.');
      } else {
        print('[SensorDataService] Unexpected error: ${response.statusCode}');
        throw Exception('Failed to update sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('[SensorDataService] Exception in updateSensorData: $e');
      throw Exception('Error updating sensor data: $e');
    }
  }

  /// Delete sensor data
  Future<bool> deleteSensorData(int sensorDataId) async {
    try {
      print('[SensorDataService] Deleting sensor data ID: $sensorDataId');
      final headers = await _authHeaders;

      final response = await http.delete(
        Uri.parse('$sensorDataEndpoint/$sensorDataId'),
        headers: headers,
      );

      print(
          '[SensorDataService] deleteSensorData response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print(
            '[SensorDataService] Successfully deleted sensor data ID: $sensorDataId');
        return true;
      } else if (response.statusCode == 404) {
        print('[SensorDataService] 404 error - sensor data not found');
        throw Exception('404: Dato de sensor no encontrado.');
      } else if (response.statusCode == 401) {
        print('[SensorDataService] 401 error - token expired or invalid');
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        print('[SensorDataService] 403 error - access denied');
        throw Exception('403: Acceso denegado.');
      } else {
        print('[SensorDataService] Unexpected error: ${response.statusCode}');
        throw Exception('Failed to delete sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('[SensorDataService] Exception in deleteSensorData: $e');
      throw Exception('Error deleting sensor data: $e');
    }
  }

  /// Convenience method for getting sensor data with better error handling
  Future<List<SensorDataModel>> getSensorDataWithRetry(
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await getAllSensorData();
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

  /// Convenience method for getting sensor data by cage with retry
  Future<List<SensorDataModel>> getSensorDataByCageWithRetry(int cageId,
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await getSensorDataByCageId(cageId);
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

/// Sensor data model based on your backend response
class SensorDataModel {
  final int id;
  final double temperature;
  final double humidity;
  final double co2;
  final double waterQuality;
  final double waterQuantity;
  final int cageId;

  SensorDataModel({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.waterQuality,
    required this.waterQuantity,
    required this.cageId,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      id: json['id'] ?? 0,
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      co2: (json['co2'] ?? 0).toDouble(),
      waterQuality: (json['waterQuality'] ?? 0).toDouble(),
      waterQuantity: (json['waterQuantity'] ?? 0).toDouble(),
      cageId: json['cageId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'waterQuality': waterQuality,
      'waterQuantity': waterQuantity,
      'cageId': cageId,
    };
  }

  /// Get temperature status based on ranges
  String get temperatureStatus {
    if (temperature < 15) return 'Muy frío';
    if (temperature <= 22) return 'Ideal';
    if (temperature <= 28) return 'Caluroso';
    return 'Muy caluroso';
  }

  /// Get humidity status based on ranges
  String get humidityStatus {
    if (humidity < 40) return 'Muy seco';
    if (humidity <= 60) return 'Ideal';
    if (humidity <= 80) return 'Húmedo';
    return 'Muy húmedo';
  }

  /// Get CO2 status based on ranges
  String get co2Status {
    if (co2 <= 1000) return 'Bueno';
    if (co2 <= 2000) return 'Aceptable';
    if (co2 <= 5000) return 'Alto';
    return 'Crítico';
  }

  /// Get water quality status based on ranges
  String get waterQualityStatus {
    if (waterQuality >= 80) return 'Excelente';
    if (waterQuality >= 60) return 'Buena';
    if (waterQuality >= 40) return 'Regular';
    return 'Mala';
  }

  /// Get water quantity status based on ranges
  String get waterQuantityStatus {
    if (waterQuantity >= 80) return 'Lleno';
    if (waterQuantity >= 50) return 'Medio';
    if (waterQuantity >= 20) return 'Bajo';
    return 'Crítico';
  }

  /// Check if any parameter is in critical range
  bool get hasCriticalValues {
    return temperature > 28 ||
        temperature < 15 ||
        humidity > 80 ||
        humidity < 40 ||
        co2 > 5000 ||
        waterQuality < 40 ||
        waterQuantity < 20;
  }
}

/// Create sensor data request model
class CreateSensorDataRequest {
  final double temperature;
  final double humidity;
  final double co2;
  final double waterQuality;
  final double waterQuantity;
  final int cageId;

  CreateSensorDataRequest({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.waterQuality,
    required this.waterQuantity,
    required this.cageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'waterQuality': waterQuality,
      'waterQuantity': waterQuantity,
      'cageId': cageId,
    };
  }
}

/// Update sensor data request model
class UpdateSensorDataRequest {
  final double temperature;
  final double humidity;
  final double co2;
  final double waterQuality;
  final double waterQuantity;
  final int cageId;

  UpdateSensorDataRequest({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.waterQuality,
    required this.waterQuantity,
    required this.cageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'waterQuality': waterQuality,
      'waterQuantity': waterQuantity,
      'cageId': cageId,
    };
  }
}
