import 'package:agrocuy/features/notifications/data/models/notification_model.dart';

class NotificationFakeRepository {
  Future<List<NotificationModel>> getAll() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula carga
    return [
      NotificationModel(
        id: 1,
        type: 'Recordatorio',
        text: 'Tu asesor Marcus Smith te ha enviado una notificación.',
        date: DateTime.now(),
        userId: 1,
      ),
      NotificationModel(
        id: 2,
        type: 'Alerta',
        text: 'La cita con Carla Rodríguez ha sido reprogramada.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        userId: 1,
      ),
    ];
  }
}
