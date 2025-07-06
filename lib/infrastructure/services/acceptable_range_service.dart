import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'session_service.dart';

class AcceptableRangeModel {
  final int? id;
  final int cageId;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;
  final double minCo2;
  final double maxCo2;
  final double minWaterQuality;
  final double maxWaterQuality;
  final double minWaterQuantity;
  final double maxWaterQuantity;
  final bool applyToAll;

  AcceptableRangeModel({
    this.id,
    required this.cageId,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minCo2,
    required this.maxCo2,
    required this.minWaterQuality,
    required this.maxWaterQuality,
    required this.minWaterQuantity,
    required this.maxWaterQuantity,
    required this.applyToAll,
  });

  factory AcceptableRangeModel.fromJson(Map<String, dynamic> json) {
    return AcceptableRangeModel(
      id: json['id'],
      cageId: json['cageId'] ?? 0,
      minTemperature: (json['minTemperature'] ?? 0).toDouble(),
      maxTemperature: (json['maxTemperature'] ?? 0).toDouble(),
      minHumidity: (json['minHumidity'] ?? 0).toDouble(),
      maxHumidity: (json['maxHumidity'] ?? 0).toDouble(),
      minCo2: (json['minCo2'] ?? 0).toDouble(),
      maxCo2: (json['maxCo2'] ?? 0).toDouble(),
      minWaterQuality: (json['minWaterQuality'] ?? 0).toDouble(),
      maxWaterQuality: (json['maxWaterQuality'] ?? 0).toDouble(),
      minWaterQuantity: (json['minWaterQuantity'] ?? 0).toDouble(),
      maxWaterQuantity: (json['maxWaterQuantity'] ?? 0).toDouble(),
      applyToAll: json['applyToAll'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cageId': cageId,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'minCo2': minCo2,
      'maxCo2': maxCo2,
      'minWaterQuality': minWaterQuality,
      'maxWaterQuality': maxWaterQuality,
      'minWaterQuantity': minWaterQuantity,
      'maxWaterQuantity': maxWaterQuantity,
      'applyToAll': applyToAll,
    };
  }

  /// Verifica si un valor está dentro del rango para temperatura
  bool isTemperatureInRange(double temperature) {
    return temperature >= minTemperature && temperature <= maxTemperature;
  }

  /// Verifica si un valor está dentro del rango para humedad
  bool isHumidityInRange(double humidity) {
    return humidity >= minHumidity && humidity <= maxHumidity;
  }

  /// Verifica si un valor está dentro del rango para CO2
  bool isCo2InRange(double co2) {
    return co2 >= minCo2 && co2 <= maxCo2;
  }

  /// Verifica si un valor está dentro del rango para calidad del agua
  bool isWaterQualityInRange(double waterQuality) {
    return waterQuality >= minWaterQuality && waterQuality <= maxWaterQuality;
  }

  /// Verifica si un valor está dentro del rango para cantidad de agua
  bool isWaterQuantityInRange(double waterQuantity) {
    return waterQuantity >= minWaterQuantity &&
        waterQuantity <= maxWaterQuantity;
  }

  /// Verifica si todos los valores de sensores están dentro de rangos aceptables
  bool areAllValuesInRange({
    required double temperature,
    required double humidity,
    required double co2,
    required double waterQuality,
    required double waterQuantity,
  }) {
    return isTemperatureInRange(temperature) &&
        isHumidityInRange(humidity) &&
        isCo2InRange(co2) &&
        isWaterQualityInRange(waterQuality) &&
        isWaterQuantityInRange(waterQuantity);
  }
}

class AcceptableRangeService extends BaseService {
  static final AcceptableRangeService _instance =
      AcceptableRangeService._internal();
  factory AcceptableRangeService() => _instance;
  AcceptableRangeService._internal();

  final SessionService _sessionService = SessionService();

  String get acceptableRangesEndpoint => '$baseUrl/acceptable-ranges';

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

  /// Verifica si el usuario está autenticado
  bool isAuthenticated() {
    return _sessionService.getToken().isNotEmpty;
  }

  /// Obtiene todos los rangos aceptables
  Future<List<AcceptableRangeModel>> getAllAcceptableRanges() async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.get(
        Uri.parse(acceptableRangesEndpoint),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => AcceptableRangeModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al obtener rangos aceptables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene el resumen global de rangos aceptables
  Future<List<AcceptableRangeModel>> getGlobalSummary() async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.get(
        Uri.parse('$acceptableRangesEndpoint/global-summary'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => AcceptableRangeModel.fromJson(item)).toList();
      } else if (response.statusCode == 204) {
        return []; // No hay rangos configurados
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al obtener rangos globales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene rangos aceptables por ID de jaula (endpoint correcto del backend)
  Future<AcceptableRangeModel?> getAcceptableRangesByCage(int cageId) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.get(
        Uri.parse('$acceptableRangesEndpoint/by-cage/$cageId'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AcceptableRangeModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No hay rangos para esta jaula
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al obtener rangos de la jaula: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Crea un nuevo rango aceptable
  Future<int> createAcceptableRange(AcceptableRangeModel range) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.post(
        Uri.parse(acceptableRangesEndpoint),
        headers: _authHeaders,
        body: json.encode(range.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData is int ? responseData : responseData['id'] ?? 0;
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al crear rango aceptable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualiza un rango aceptable existente
  Future<void> updateAcceptableRange(int id, AcceptableRangeModel range) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.put(
        Uri.parse('$acceptableRangesEndpoint/$id'),
        headers: _authHeaders,
        body: json.encode(range.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      } else if (response.statusCode == 404) {
        throw Exception('Rango aceptable no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al actualizar rango aceptable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Elimina un rango aceptable
  Future<bool> deleteAcceptableRange(int id) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$acceptableRangesEndpoint/$id'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Rango aceptable no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al eliminar rango aceptable: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Método con reintentos para obtener rangos por jaula
  Future<AcceptableRangeModel?> getAcceptableRangesByCageWithRetry(int cageId,
      {int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await getAcceptableRangesByCage(cageId);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(
              Duration(seconds: attempts * 2)); // Backoff exponencial
        }
      }
    }

    throw lastException ??
        Exception('Error desconocido al obtener rangos aceptables');
  }

  /// Método con reintentos para obtener todos los rangos
  Future<List<AcceptableRangeModel>> getAllAcceptableRangesWithRetry(
      {int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await getAllAcceptableRanges();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(
              Duration(seconds: attempts * 2)); // Backoff exponencial
        }
      }
    }

    throw lastException ??
        Exception('Error desconocido al obtener rangos aceptables');
  }

  /// Verifica si los valores de sensores están dentro de los rangos aceptables para una jaula
  Map<String, bool> checkSensorValues({
    required AcceptableRangeModel range,
    required double temperature,
    required double humidity,
    required double co2,
    required double waterQuality,
    required double waterQuantity,
  }) {
    return {
      'temperature': range.isTemperatureInRange(temperature),
      'humidity': range.isHumidityInRange(humidity),
      'co2': range.isCo2InRange(co2),
      'waterQuality': range.isWaterQualityInRange(waterQuality),
      'waterQuantity': range.isWaterQuantityInRange(waterQuantity),
    };
  }

  /// Obtiene las violaciones de rangos actuales
  List<String> getRangeViolations({
    required AcceptableRangeModel range,
    required double temperature,
    required double humidity,
    required double co2,
    required double waterQuality,
    required double waterQuantity,
  }) {
    List<String> violations = [];

    if (!range.isTemperatureInRange(temperature)) {
      violations.add(
          'Temperatura fuera del rango (${range.minTemperature}°C - ${range.maxTemperature}°C)');
    }

    if (!range.isHumidityInRange(humidity)) {
      violations.add(
          'Humedad fuera del rango (${range.minHumidity}% - ${range.maxHumidity}%)');
    }

    if (!range.isCo2InRange(co2)) {
      violations.add(
          'CO2 fuera del rango (${range.minCo2} ppm - ${range.maxCo2} ppm)');
    }

    if (!range.isWaterQualityInRange(waterQuality)) {
      violations.add(
          'Calidad del agua fuera del rango (${range.minWaterQuality} - ${range.maxWaterQuality})');
    }

    if (!range.isWaterQuantityInRange(waterQuantity)) {
      violations.add(
          'Cantidad de agua fuera del rango (${range.minWaterQuantity}ml - ${range.maxWaterQuantity}ml)');
    }

    return violations;
  }
}
