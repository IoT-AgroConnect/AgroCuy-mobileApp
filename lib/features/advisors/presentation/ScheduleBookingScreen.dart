import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/models/available_date_model.dart';

class ScheduleBookingScreen extends StatelessWidget {
  final List<ScheduleModel> schedules;

  const ScheduleBookingScreen({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    final availableSchedules = schedules.where((s) => s.status == 'Disponible').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reservar Cita')),
      body: availableSchedules.isEmpty
          ? _buildNoSchedules(context)
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Elige tu horario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: availableSchedules.length,
              itemBuilder: (context, index) {
                final schedule = availableSchedules[index];
                return _buildScheduleCard(context, schedule);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, ScheduleModel schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.asset('assets/images/cuy.png', width: 50, height: 50),
        title: Text('Fecha: ${schedule.date.toLocal().toString().split(' ')[0]}'),
        subtitle: Text(
          'Hora Inicio: ${schedule.startTime}\nHora Fin: ${schedule.endTime}\nEstado: ${schedule.status}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showActionPopup(context, schedule),
        ),
      ),
    );
  }

  void _showActionPopup(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Deseas reservar esta cita?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Reservar'),
            onPressed: () {
              Navigator.pop(context);
              _showConfirmationPopup(context);
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmationPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/cuy.png', width: 100, height: 100),
            const SizedBox(height: 16),
            const Text(
              'Cita Reservada con éxito',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Su asesor se contactará con usted en breve.'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Volver al inicio'),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSchedules(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('El asesor no tiene horarios disponibles', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Image.asset('assets/images/cuy.png', width: 150, height: 150),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Volver al inicio'),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
