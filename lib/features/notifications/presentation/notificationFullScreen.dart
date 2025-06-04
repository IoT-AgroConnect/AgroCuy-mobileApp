import 'package:flutter/material.dart';
import 'package:agrocuy/features/notifications/data/models/notification_model.dart';
import 'package:agrocuy/features/notifications/data/datasources/notification_remote_data_source.dart';

import '../domain/repositories/notification_fake_repository.dart';
import 'notificationCardScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  //late final NotificationRepository _repository;
  late final NotificationFakeRepository _repository;
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
     //_repository = NotificationRepository(NotificationRemoteDataSource());
    _repository = NotificationFakeRepository();
    _notificationsFuture = _repository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay notificaciones.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(notification: notifications[index], onDelete: () {  },);
            },
          );
        },
      ),
    );
  }
}
