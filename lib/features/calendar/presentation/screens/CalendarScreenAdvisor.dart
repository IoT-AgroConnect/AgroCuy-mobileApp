import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreenAdvisor extends StatefulWidget {
  final int advisorId;
  final String fullname;
  final String username;
  final String photoUrl;

  const CalendarScreenAdvisor({
    super.key,
    required this.advisorId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
  });

  @override
  State<CalendarScreenAdvisor> createState() => _CalendarScreenAdvisorState();
}

class _CalendarScreenAdvisorState extends State<CalendarScreenAdvisor> {
  // Eventos con información detallada del cliente y la cita
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.utc(2025, 6, 18): [
      {
        'title': 'Consulta con Juan Pérez',
        'time': '09:00',
        'type': 'consulta',
        'estado': 'programada',
        'description': 'Revisión de cuyes reproductores',
        'priority': 'alta',
        'cliente': {
          'nombre': 'Juan Pérez Hernández',
          'descripcion': 'Criador especializado en cuyes reproductores',
          'cantidadJaulas': 15,
          'ubicacion': 'Lima, Perú - Sector A',
        }
      }
    ],
    DateTime.utc(2025, 6, 20): [
      {
        'title': 'Visita a María González',
        'time': '13:00',
        'type': 'visita',
        'estado': 'confirmada',
        'description': 'Inspección de instalaciones y jaulas nuevas',
        'priority': 'media',
        'cliente': {
          'nombre': 'María González López',
          'descripcion': 'Granja familiar con enfoque en calidad',
          'cantidadJaulas': 8,
          'ubicacion': 'Cusco, Perú - Zona Rural',
        }
      }
    ],
    DateTime.utc(2025, 6, 22): [
      {
        'title': 'Capacitación - Carlos Mendoza',
        'time': '15:00',
        'type': 'capacitacion',
        'estado': 'programada',
        'description': 'Técnicas de alimentación y nutrición',
        'priority': 'alta',
        'cliente': {
          'nombre': 'Carlos Mendoza Ríos',
          'descripcion': 'Nuevo criador, requiere capacitación básica',
          'cantidadJaulas': 5,
          'ubicacion': 'Arequipa, Perú - Centro',
        }
      }
    ],
    DateTime.utc(2025, 6, 25): [
      {
        'title': 'Reunión - Ana Torres',
        'time': '18:00',
        'type': 'reunion',
        'estado': 'pendiente',
        'description': 'Planificación mensual y estrategias',
        'priority': 'baja',
        'cliente': {
          'nombre': 'Ana Torres Vega',
          'descripcion': 'Criadora experimentada, socia estratégica',
          'cantidadJaulas': 25,
          'ubicacion': 'Trujillo, Perú - Industrial',
        }
      }
    ],
  };

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _updateSelectedEvents();
  }

  void _updateSelectedEvents() {
    if (_selectedDay != null) {
      final key = DateTime.utc(
          _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _selectedEvents = _events[key] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'Calendario - Asesor'),
      drawer: UserDrawerAdvisor(
        fullname: widget.fullname,
        username: widget.username.split('@').first,
        photoUrl: widget.photoUrl,
        advisorId: widget.advisorId,
      ),
      body: Column(
        children: [
          // Header con información del mes
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Citas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMonthName(_focusedDay.month),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getTotalEvents()} citas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Calendario
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _updateSelectedEvents();
                });
              },
              eventLoader: (day) {
                final key = DateTime.utc(day.year, day.month, day.day);
                return _events[key] ?? [];
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Color(0xFF8B4513),
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8B4513),
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF8B4513),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFD2691E),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(
                  color: Colors.red,
                ),
                defaultTextStyle: const TextStyle(
                  color: Colors.black87,
                ),
              ),
              locale: 'es_ES',
            ),
          ),

          const SizedBox(height: 16),

          // Eventos del día seleccionado
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: const Color(0xFF8B4513),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDay != null
                            ? 'Eventos del ${_formatSelectedDate()}'
                            : 'Selecciona una fecha',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _selectedEvents.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _selectedEvents.length,
                            itemBuilder: (context, index) {
                              final event = _selectedEvents[index];
                              return _buildEventCard(event);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay eventos programados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'para esta fecha',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    Color eventColor = _getEventColor(event['type']);
    Color priorityColor = _getPriorityColor(event['priority']);
    Color estadoColor = _getEstadoColor(event['estado']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEventDetailsDialog(event),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: eventColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event['priority'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['time'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        _getEventIcon(event['type']),
                        size: 16,
                        color: eventColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['type'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: eventColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: estadoColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['estado'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: estadoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Información del cliente resumida
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Cliente: ${event['cliente']['nombre']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'Toca para ver detalles',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (event['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      event['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetailsDialog(Map<String, dynamic> event) {
    final cliente = event['cliente'];
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getEventIcon(event['type']),
                    color: _getEventColor(event['type']),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Detalles de la Cita',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Información de la cita
              _buildDetailSection(
                'Información de la Cita',
                Icons.event_note,
                [
                  _buildDetailRow('Título:', event['title']),
                  _buildDetailRow('Descripción:', event['description']),
                  _buildDetailRow('Estado:', event['estado']),
                  _buildDetailRow('Fecha programada:', _formatSelectedDate()),
                  _buildDetailRow('Hora:', event['time']),
                  _buildDetailRow('Tipo:', event['type']),
                  _buildDetailRow('Prioridad:', event['priority']),
                ],
              ),

              const SizedBox(height: 16),

              // Información del cliente
              _buildDetailSection(
                'Información del Cliente',
                Icons.person,
                [
                  _buildDetailRow('Nombre:', cliente['nombre']),
                  _buildDetailRow('Descripción:', cliente['descripcion']),
                  _buildDetailRow('Cantidad de jaulas:',
                      cliente['cantidadJaulas'].toString()),
                  _buildDetailRow('Ubicación:', cliente['ubicacion']),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí podrías navegar a una pantalla de edición
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Aquí podrías abrir un chat o llamada
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Contactar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B4513),
                        side: const BorderSide(color: Color(0xFF8B4513)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
      String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8B4513)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'consulta':
        return Colors.blue;
      case 'visita':
        return Colors.green;
      case 'capacitacion':
        return Colors.orange;
      case 'reunion':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'programada':
        return Colors.blue;
      case 'confirmada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'consulta':
        return Icons.medical_services;
      case 'visita':
        return Icons.visibility;
      case 'capacitacion':
        return Icons.school;
      case 'reunion':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }

  String _formatSelectedDate() {
    if (_selectedDay == null) return '';
    return '${_selectedDay!.day} de ${_getMonthName(_selectedDay!.month)}';
  }

  int _getTotalEvents() {
    return _events.values.fold(0, (total, events) => total + events.length);
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Cita'),
        content:
            const Text('Función para agregar nueva cita\n(Por implementar)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
