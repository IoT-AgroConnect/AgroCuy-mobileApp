import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'session_service.dart';

class SensorDataService extends BaseService {
  static final SensorDataService _instance = SensorDataService._internal();
  final SessionService _sessionService = SessionService();

  // For real-time updates
  final Map<int, StreamController<List<SensorDataModel>>> _cageDataStreams = {};
  final Map<int, Timer> _refreshTimers = {};

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

  /// Get sensor data by cage ID - Updated to filter from all sensor data
  Future<List<SensorDataModel>> getSensorDataByCageId(int cageId) async {
    try {
      print('[SensorDataService] Getting sensor data for cage ID: $cageId');

      // Get all sensor data from the new endpoint
      final allSensorData = await getAllSensorData();

      // Filter by cageId and sort by most recent (timestamp first, then id)
      final filteredData =
          allSensorData.where((data) => data.cageId == cageId).toList()
            ..sort((a, b) {
              // Sort by timestamp if available, otherwise by id
              if (a.timestamp != null && b.timestamp != null) {
                return b.timestamp!.compareTo(a.timestamp!);
              } else {
                return b.id.compareTo(a.id); // Most recent id first
              }
            });

      print(
          '[SensorDataService] Filtered ${filteredData.length} sensor data records for cage $cageId');

      return filteredData;
    } catch (e) {
      print('[SensorDataService] Exception in getSensorDataByCageId: $e');
      throw Exception('Error fetching sensor data by cage: $e');
    }
  }

  /// Get latest sensor data for a cage
  Future<SensorDataModel?> getLatestSensorDataByCageId(int cageId) async {
    try {
      print(
          '[SensorDataService] Getting latest sensor data for cage ID: $cageId');

      final sensorDataList = await getSensorDataByCageId(cageId);

      if (sensorDataList.isNotEmpty) {
        print('[SensorDataService] Found latest sensor data for cage $cageId');
        return sensorDataList.first; // Already sorted by most recent
      }

      print('[SensorDataService] No sensor data found for cage $cageId');
      return null;
    } catch (e) {
      print('[SensorDataService] Exception in getLatestSensorDataByCageId: $e');
      throw Exception('Error fetching latest sensor data: $e');
    }
  }

  /// Create a stream of sensor data for a specific cage with auto-refresh every 5 seconds
  Stream<List<SensorDataModel>> getSensorDataStreamByCageId(int cageId) {
    print(
        '[SensorDataService] Creating sensor data stream for cage ID: $cageId');

    // Close existing stream if any
    _closeCageStream(cageId);

    // Create new stream controller
    final controller = StreamController<List<SensorDataModel>>.broadcast();
    _cageDataStreams[cageId] = controller;

    // Function to fetch and emit data
    Future<void> fetchAndEmit() async {
      try {
        final data = await getSensorDataByCageId(cageId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      } catch (e) {
        print('[SensorDataService] Error in stream for cage $cageId: $e');
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    // Initial fetch
    fetchAndEmit();

    // Set up periodic timer for auto-refresh every 5 seconds
    _refreshTimers[cageId] = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!controller.isClosed) {
        fetchAndEmit();
      } else {
        timer.cancel();
        _refreshTimers.remove(cageId);
      }
    });

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _closeCageStream(cageId);
    };

    return controller.stream;
  }

  /// Get latest sensor data stream for a specific cage with auto-refresh every 5 seconds
  Stream<SensorDataModel?> getLatestSensorDataStreamByCageId(int cageId) {
    print(
        '[SensorDataService] Creating latest sensor data stream for cage ID: $cageId');

    return getSensorDataStreamByCageId(cageId).map((dataList) {
      return dataList.isNotEmpty ? dataList.first : null;
    });
  }

  /// Close stream and timer for a specific cage
  void _closeCageStream(int cageId) {
    // Cancel timer
    _refreshTimers[cageId]?.cancel();
    _refreshTimers.remove(cageId);

    // Close stream controller
    _cageDataStreams[cageId]?.close();
    _cageDataStreams.remove(cageId);

    print('[SensorDataService] Closed stream for cage ID: $cageId');
  }

  /// Close all streams and timers
  void closeAllStreams() {
    print('[SensorDataService] Closing all sensor data streams');

    final cageIds = List<int>.from(_cageDataStreams.keys);
    for (final cageId in cageIds) {
      _closeCageStream(cageId);
    }
  }

  /// Dispose method to clean up resources
  void dispose() {
    closeAllStreams();
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

  /// Manually refresh sensor data for a specific cage
  Future<void> refreshSensorDataByCageId(int cageId) async {
    print('[SensorDataService] Manual refresh requested for cage ID: $cageId');

    // Get the stream controller for this cage
    final controller = _cageDataStreams[cageId];
    if (controller != null && !controller.isClosed) {
      try {
        final data = await getSensorDataByCageId(cageId);
        controller.add(data);
        print('[SensorDataService] Manual refresh completed for cage $cageId');
      } catch (e) {
        print(
            '[SensorDataService] Error in manual refresh for cage $cageId: $e');
        controller.addError(e);
      }
    } else {
      print('[SensorDataService] No active stream found for cage $cageId');
    }
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
  final DateTime? timestamp;

  SensorDataModel({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.waterQuality,
    required this.waterQuantity,
    required this.cageId,
    this.timestamp,
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
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
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
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Get the most recent sensor data based on timestamp or id
  bool isMoreRecentThan(SensorDataModel other) {
    if (timestamp != null && other.timestamp != null) {
      return timestamp!.isAfter(other.timestamp!);
    }
    // Fallback to id comparison if no timestamp
    return id > other.id;
  }

  /// Get formatted timestamp string
  String get formattedTimestamp {
    if (timestamp != null) {
      return '${timestamp!.day}/${timestamp!.month}/${timestamp!.year} ${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}';
    }
    return 'Fecha no disponible';
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
