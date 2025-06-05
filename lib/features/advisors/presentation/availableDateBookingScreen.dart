import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/available_date_model.dart';

class AvailableDatesScreen extends StatelessWidget {
  final List<AvailableDateModel> AvailableDates;

  const AvailableDatesScreen({super.key, required this.AvailableDates});

  void _showConfirmDialog(BuildContext context, AvailableDateModel AvailableDate) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar reserva'),
        content: Text(
            '¿Deseas reservar esta cita?\n\n${DateFormat('yyyy-MM-dd').format(AvailableDate.date)}\n${AvailableDate.startTime} - ${AvailableDate.endTime}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // cerrar confirmación
              _showSuccessDialog(context);
            },
            child: const Text('Reservar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          'Cita Reservada con éxito',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/cuy_success.png', height: 120),
            const SizedBox(height: 12),
            const Text('Su asesor se contactará con usted en breve.'),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Volver al inicio'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableAvailableDates =
    AvailableDates.where((s) => s.status == 'Disponible').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Cita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: availableAvailableDates.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'El asesor no tiene horarios disponibles.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/cuy_sad.png', height: 150),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver al inicio'),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reservar Cita - Elige tu horario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: availableAvailableDates.length,
                itemBuilder: (context, index) {
                  final AvailableDate = availableAvailableDates[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/cuy_AvailableDate.png',
                        height: 50,
                        width: 50,
                      ),
                      title: Text(
                          'Fecha: ${DateFormat('yyyy-MM-dd').format(AvailableDate.date)}'),
                      subtitle: Text(
                        'Hora Inicio: ${AvailableDate.startTime}\nHora Fin: ${AvailableDate.endTime}\nEstado: ${AvailableDate.status}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.event_available),
                        onPressed: () =>
                            _showConfirmDialog(context, AvailableDate),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
