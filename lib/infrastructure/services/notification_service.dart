import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrocuy/features/notifications/data/models/notification_model.dart';
import 'base_service.dart';
import 'session_service.dart';

class NotificationService extends BaseService {
  static final NotificationService _instance = NotificationService._internal();
  final SessionService _sessionService = SessionService();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  String get notificationsEndpoint => '$baseUrl/notifications';

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

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(notificationsEndpoint),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception(
            '403: Acceso denegado. No tienes permisos para ver las notificaciones.');
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
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(int notificationId) async {
    try {
      final response = await http.get(
        Uri.parse('$notificationsEndpoint/$notificationId'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return NotificationModel.fromJson(json);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception(
            '401: No autorizado. El token ha expirado o es inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('403: Acceso denegado.');
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notification: $e');
    }
  }

  /// Create a new notification
  Future<NotificationModel?> createNotification(
      CreateNotificationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(notificationsEndpoint),
        headers: _authHeaders,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return NotificationModel.fromJson(json);
      } else {
        throw Exception(
            'Failed to create notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$notificationsEndpoint/$notificationId'),
        headers: _authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  /// Convenience method for getting notifications with better error handling
  Future<List<NotificationModel>> getNotificationsWithRetry(
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await getAllNotifications();
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

/// Create notification request model
class CreateNotificationRequest {
  final String type;
  final String text;
  final int userId;
  final String? meetingUrl;

  CreateNotificationRequest({
    required this.type,
    required this.text,
    required this.userId,
    this.meetingUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'userId': userId,
      'meetingUrl': meetingUrl,
    };
  }
}
