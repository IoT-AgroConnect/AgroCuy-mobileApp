import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'session_service.dart';

class FeedingScheduleModel {
  final int? id;
  final int cageId;
  final String morningTime;
  final String eveningTime;
  final bool applyToAll;

  FeedingScheduleModel({
    this.id,
    required this.cageId,
    required this.morningTime,
    required this.eveningTime,
    required this.applyToAll,
  });

  factory FeedingScheduleModel.fromJson(Map<String, dynamic> json) {
    return FeedingScheduleModel(
      id: json['id'],
      cageId: json['cageId'] ?? 0,
      morningTime: json['morningTime'] ?? '',
      eveningTime: json['eveningTime'] ?? '',
      applyToAll: json['applyToAll'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cageId': cageId,
      'morningTime': morningTime,
      'eveningTime': eveningTime,
      'applyToAll': applyToAll,
    };
  }
}

class FeedingScheduleService extends BaseService {
  static final FeedingScheduleService _instance =
      FeedingScheduleService._internal();
  factory FeedingScheduleService() => _instance;
  FeedingScheduleService._internal();

  final SessionService _sessionService = SessionService();

  String get feedingSchedulesEndpoint => '$baseUrl/feeding-schedules';

  /// Get the authorization headers with token (async)
  Future<Map<String, String>> get _authHeaders async {
    print('[FeedingScheduleService] Getting auth headers...');

    // Ensure session is initialized
    await _sessionService.init();

    final token = _sessionService.getToken();
    print(
        '[FeedingScheduleService] Token retrieved: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Empty"}');

    if (token.isNotEmpty) {
      final headers = getHeaders(token);
      print('[FeedingScheduleService] Auth headers created with token');
      return headers;
    } else {
      print('[FeedingScheduleService] No token available, using basic headers');
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

  /// Obtiene todos los horarios de alimentación
  Future<List<FeedingScheduleModel>> getAllFeedingSchedules() async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      print('[FeedingScheduleService] Getting all feeding schedules...');
      final headers = await _authHeaders;

      final response = await http.get(
        Uri.parse(feedingSchedulesEndpoint),
        headers: headers,
      );

      print(
          '[FeedingScheduleService] getAllFeedingSchedules response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(
            '[FeedingScheduleService] Retrieved ${data.length} feeding schedules');
        return data.map((item) => FeedingScheduleModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        print('[FeedingScheduleService] 401 error - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '[FeedingScheduleService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Error al obtener horarios de alimentación: ${response.statusCode}');
      }
    } catch (e) {
      print('[FeedingScheduleService] Exception in getAllFeedingSchedules: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene el horario de alimentación más reciente (global summary)
  Future<FeedingScheduleModel?> getGlobalSummary() async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      print('[FeedingScheduleService] Getting global summary...');
      final headers = await _authHeaders;

      final response = await http.get(
        Uri.parse('$feedingSchedulesEndpoint/global-summary'),
        headers: headers,
      );

      print(
          '[FeedingScheduleService] getGlobalSummary response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('[FeedingScheduleService] Retrieved global summary');
        return FeedingScheduleModel.fromJson(data);
      } else if (response.statusCode == 204) {
        print('[FeedingScheduleService] No feeding schedules configured');
        return null; // No hay horarios configurados
      } else if (response.statusCode == 401) {
        print('[FeedingScheduleService] 401 error - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '[FeedingScheduleService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Error al obtener horario global: ${response.statusCode}');
      }
    } catch (e) {
      print('[FeedingScheduleService] Exception in getGlobalSummary: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene horarios de alimentación por ID de jaula
  Future<List<FeedingScheduleModel>> getFeedingSchedulesByCage(
      int cageId) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final allSchedules = await getAllFeedingSchedules();
      return allSchedules
          .where((schedule) => schedule.cageId == cageId)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener horarios de la jaula: ${e.toString()}');
    }
  }

  /// Crea un nuevo horario de alimentación
  Future<dynamic> createFeedingSchedule(FeedingScheduleModel schedule) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      print(
          '[FeedingScheduleService] Creating feeding schedule for cage: ${schedule.cageId}');
      final headers = await _authHeaders;

      final response = await http.post(
        Uri.parse(feedingSchedulesEndpoint),
        headers: headers,
        body: json.encode(schedule.toJson()),
      );

      print(
          '[FeedingScheduleService] createFeedingSchedule response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Si es un mensaje de éxito para horario global
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          print(
              '[FeedingScheduleService] Global schedule created successfully');
          return responseData;
        } else {
          print(
              '[FeedingScheduleService] Individual schedule created successfully');
          return FeedingScheduleModel.fromJson(responseData);
        }
      } else if (response.statusCode == 401) {
        print('[FeedingScheduleService] 401 error - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '[FeedingScheduleService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Error al crear horario de alimentación: ${response.statusCode}');
      }
    } catch (e) {
      print('[FeedingScheduleService] Exception in createFeedingSchedule: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualiza un horario de alimentación existente
  Future<FeedingScheduleModel> updateFeedingSchedule(
      int id, FeedingScheduleModel schedule) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      print('[FeedingScheduleService] Updating feeding schedule ID: $id');
      final headers = await _authHeaders;

      final response = await http.put(
        Uri.parse('$feedingSchedulesEndpoint/$id'),
        headers: headers,
        body: json.encode(schedule.toJson()),
      );

      print(
          '[FeedingScheduleService] updateFeedingSchedule response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(
            '[FeedingScheduleService] Successfully updated feeding schedule ID: $id');
        return FeedingScheduleModel.fromJson(data);
      } else if (response.statusCode == 404) {
        print(
            '[FeedingScheduleService] 404 error - feeding schedule not found');
        throw Exception('Horario de alimentación no encontrado.');
      } else if (response.statusCode == 401) {
        print('[FeedingScheduleService] 401 error - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '[FeedingScheduleService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Error al actualizar horario de alimentación: ${response.statusCode}');
      }
    } catch (e) {
      print('[FeedingScheduleService] Exception in updateFeedingSchedule: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualiza todos los horarios de alimentación globalmente
  Future<Map<String, dynamic>> updateAllFeedingSchedules({
    required String morningTime,
    required String eveningTime,
  }) async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      print('[FeedingScheduleService] Updating all feeding schedules globally');
      final headers = await _authHeaders;

      final response = await http.put(
        Uri.parse('$feedingSchedulesEndpoint/global'),
        headers: headers,
        body: json.encode({
          'morningTime': morningTime,
          'eveningTime': eveningTime,
        }),
      );

      print(
          '[FeedingScheduleService] updateAllFeedingSchedules response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(
            '[FeedingScheduleService] Successfully updated all feeding schedules globally');
        return data;
      } else if (response.statusCode == 401) {
        print('[FeedingScheduleService] 401 error - session expired');
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        print(
            '[FeedingScheduleService] Unexpected error: ${response.statusCode}');
        throw Exception(
            'Error al actualizar horarios globales: ${response.statusCode}');
      }
    } catch (e) {
      print(
          '[FeedingScheduleService] Exception in updateAllFeedingSchedules: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Método con reintentos para obtener horarios por jaula
  Future<List<FeedingScheduleModel>> getFeedingSchedulesByCageWithRetry(
      int cageId,
      {int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await getFeedingSchedulesByCage(cageId);
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
        Exception('Error desconocido al obtener horarios de alimentación');
  }

  /// Método con reintentos para obtener todos los horarios
  Future<List<FeedingScheduleModel>> getAllFeedingSchedulesWithRetry(
      {int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await getAllFeedingSchedules();
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
        Exception('Error desconocido al obtener horarios de alimentación');
  }
}
