import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../infrastructure/services/base_service.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource extends BaseService {
  Future<List<NotificationModel>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener notificaciones: ${response.statusCode} ${response.body}');
    }
  }

  Future<NotificationModel> getNotificationById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener notificación');
    }
  }

  Future<void> createNotification(NotificationModel notification, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notification.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear notificación: ${response.body}');
    }
  }

  Future<void> updateNotification(int id, Map<String, dynamic> data, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar notificación: ${response.body}');
    }
  }

  Future<void> deleteNotification(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar notificación');
    }
  }
}
