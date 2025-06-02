import 'package:flutter/material.dart';
import 'package:agrocuy/features/notifications/data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({Key? key, required this.notification}) : super(key: key);

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cita':
        return Icons.calendar_today;
      case 'recordatorio':
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy – HH:mm').format(notification.date);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(_getIcon(notification.type), color: Colors.deepPurple),
        title: Text(notification.text),
        subtitle: Text(dateFormatted),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            // Puedes implementar la lógica para borrar la notificación aquí
          },
        ),
      ),
    );
  }
}
