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

  /// Obtiene todos los horarios de alimentación
  Future<List<FeedingScheduleModel>> getAllFeedingSchedules() async {
    if (!isAuthenticated()) {
      throw Exception(
          'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
    }

    try {
      final response = await http.get(
        Uri.parse(feedingSchedulesEndpoint),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => FeedingScheduleModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al obtener horarios de alimentación: ${response.statusCode}');
      }
    } catch (e) {
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
      final response = await http.get(
        Uri.parse('$feedingSchedulesEndpoint/global-summary'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return FeedingScheduleModel.fromJson(data);
      } else if (response.statusCode == 204) {
        return null; // No hay horarios configurados
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al obtener horario global: ${response.statusCode}');
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse(feedingSchedulesEndpoint),
        headers: _authHeaders,
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Si es un mensaje de éxito para horario global
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          return responseData;
        } else {
          return FeedingScheduleModel.fromJson(responseData);
        }
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al crear horario de alimentación: ${response.statusCode}');
      }
    } catch (e) {
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
      final response = await http.put(
        Uri.parse('$feedingSchedulesEndpoint/$id'),
        headers: _authHeaders,
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return FeedingScheduleModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Horario de alimentación no encontrado.');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al actualizar horario de alimentación: ${response.statusCode}');
      }
    } catch (e) {
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
      final response = await http.put(
        Uri.parse('$feedingSchedulesEndpoint/global'),
        headers: _authHeaders,
        body: json.encode({
          'morningTime': morningTime,
          'eveningTime': eveningTime,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error al actualizar horarios globales: ${response.statusCode}');
      }
    } catch (e) {
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
