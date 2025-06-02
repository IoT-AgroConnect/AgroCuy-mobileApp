
import 'package:agrocuy/infrastructure/services/session_service.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_model.dart';

class NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final SessionService _session = SessionService();

  NotificationRepository(this.remoteDataSource);

  Future<List<NotificationModel>> getAll() async {
    final token = _session.getToken();
    return remoteDataSource.getNotifications(token);
  }

  Future<NotificationModel> getById(int id) async {
    final token = _session.getToken();
    return remoteDataSource.getNotificationById(id, token);
  }

  Future<void> create(NotificationModel notification) async {
    final token = _session.getToken();
    return remoteDataSource.createNotification(notification, token);
  }

  Future<void> update(int id, NotificationModel notification) async {
    final token = _session.getToken();
    return remoteDataSource.updateNotification(id, notification.toJson(), token);
  }

  Future<void> delete(int id) async {
    final token = _session.getToken();
    return remoteDataSource.deleteNotification(id, token);
  }
}