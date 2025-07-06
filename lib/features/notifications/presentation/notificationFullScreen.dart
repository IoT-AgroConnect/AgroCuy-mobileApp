import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import 'package:agrocuy/features/notifications/data/models/notification_model.dart';
import 'package:agrocuy/infrastructure/services/notification_service.dart';
import 'package:agrocuy/infrastructure/services/session_service.dart';

import 'notificationCardScreen.dart';

class NotificationScreen extends StatefulWidget {
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const NotificationScreen({
    Key? key,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationService _notificationService;
  late final SessionService _sessionService;
  late Future<List<NotificationModel>> _notificationsFuture;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _sessionService = SessionService();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ensure session is initialized
      await _sessionService.init();

      if (!_notificationService.isAuthenticated()) {
        throw Exception(
            'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      _notificationsFuture = _notificationService.getNotificationsWithRetry();
      await _notificationsFuture; // Wait to catch any errors
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final success =
          await _notificationService.deleteNotification(notificationId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadNotifications(); // Reload notifications
      } else {
        throw Exception('No se pudo eliminar la notificación');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar notificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'Notificaciones'),
      drawer: widget.role == 'ROLE_BREEDER'
          ? UserDrawerBreeder(
              fullname: widget.fullname,
              username: widget.username.split('@').first,
              photoUrl: widget.photoUrl,
              userId: widget.userId,
              role: widget.role,
            )
          : UserDrawerAdvisor(
              fullname: widget.fullname,
              username: widget.username.split('@').first,
              photoUrl: widget.photoUrl,
              advisorId: widget.userId,
            ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return FutureBuilder<List<NotificationModel>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final errorMsg =
              snapshot.error.toString().replaceFirst('Exception: ', '');
          if (errorMsg.contains('401') || errorMsg.contains('autorizado')) {
            return _buildAuthErrorWidget();
          }
          return _buildErrorWidget(errorMsg);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyWidget();
        }

        final notifications = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return NotificationCard(
              notification: notifications[index],
              onDelete: () => _deleteNotification(notifications[index].id),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorWidget([String? customMessage]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar notificaciones',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            customMessage ?? _errorMessage ?? 'Ha ocurrido un error inesperado',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Sesión expirada',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes notificaciones en este momento.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
