import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import 'package:agrocuy/infrastructure/services/animal_service.dart'
    as animal_svc;
import 'package:agrocuy/infrastructure/services/sensor_data_service.dart';
import 'package:agrocuy/infrastructure/services/feeding_schedule_service.dart';
import 'package:agrocuy/infrastructure/services/acceptable_range_service.dart';
import 'package:agrocuy/infrastructure/services/session_service.dart';
import '../data/models/jaula_model.dart';
import 'cuy_form_screen.dart';

class JaulaDetailScreen extends StatefulWidget {
  final JaulaModel jaula;
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const JaulaDetailScreen({
    super.key,
    required this.jaula,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  });

  @override
  State<JaulaDetailScreen> createState() => _JaulaDetailScreenState();
}

class _JaulaDetailScreenState extends State<JaulaDetailScreen> {
  late final animal_svc.AnimalService _animalService;
  late final SensorDataService _sensorDataService;
  late final FeedingScheduleService _feedingScheduleService;
  late final AcceptableRangeService _acceptableRangeService;
  late final SessionService _sessionService;

  late Future<List<animal_svc.AnimalModel>> _animalsFuture;
  late Future<List<FeedingScheduleModel>> _feedingSchedulesFuture;
  late Future<AcceptableRangeModel?> _acceptableRangesFuture;

  // Real-time sensor data stream
  StreamSubscription<SensorDataModel?>? _sensorDataSubscription;
  SensorDataModel? _latestSensorData;
  DateTime? _lastSensorUpdateTime;
  bool _isRefreshingSensorData = false;

  AcceptableRangeModel? _currentRanges;
  List<FeedingScheduleModel> _feedingSchedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animalService = animal_svc.AnimalService();
    _sensorDataService = SensorDataService();
    _feedingScheduleService = FeedingScheduleService();
    _acceptableRangeService = AcceptableRangeService();
    _sessionService = SessionService();
    _loadData();
    _setupSensorDataStream();
  }

  @override
  void dispose() {
    _sensorDataSubscription?.cancel();
    _sensorDataService.closeAllStreams();
    super.dispose();
  }

  /// Setup real-time sensor data stream
  void _setupSensorDataStream() {
    print(
        '[JaulaDetailScreen] Setting up sensor data stream for cage ${widget.jaula.id}');

    _sensorDataSubscription = _sensorDataService
        .getLatestSensorDataStreamByCageId(widget.jaula.id)
        .listen(
      (sensorData) {
        print(
            '[JaulaDetailScreen] Received sensor data update: ${sensorData?.id}');
        setState(() {
          _latestSensorData = sensorData;
          _lastSensorUpdateTime = DateTime.now();
        });
      },
      onError: (error) {
        print('[JaulaDetailScreen] Sensor data stream error: $error');
        // Optionally show error, but don't override main error message
      },
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ensure session is initialized
      await _sessionService.init();

      if (!_animalService.isAuthenticated()) {
        throw Exception(
            'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      // Load all data in parallel (excluding sensor data since it's now streamed)
      _animalsFuture =
          _animalService.getAnimalsByCageIdWithRetry(widget.jaula.id);
      _feedingSchedulesFuture = _feedingScheduleService
          .getFeedingSchedulesByCageWithRetry(widget.jaula.id);
      _acceptableRangesFuture = _acceptableRangeService
          .getAcceptableRangesByCageWithRetry(widget.jaula.id);

      // Get current acceptable ranges
      _currentRanges = await _acceptableRangesFuture;

      // Get feeding schedules
      _feedingSchedules = await _feedingSchedulesFuture;

      await _animalsFuture; // Wait to catch any errors
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

  Future<void> _loadAnimals() async {
    setState(() {
      _animalsFuture =
          _animalService.getAnimalsByCageIdWithRetry(widget.jaula.id);
    });
  }

  /// Manual refresh of sensor data
  Future<void> _refreshSensorData() async {
    print(
        '[JaulaDetailScreen] Manual sensor data refresh requested for cage ${widget.jaula.id}');

    setState(() {
      _isRefreshingSensorData = true;
    });

    try {
      await _sensorDataService.refreshSensorDataByCageId(widget.jaula.id);

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Datos actualizados'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('[JaulaDetailScreen] Error refreshing sensor data: $e');

      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Error al actualizar: ${e.toString().replaceFirst('Exception: ', '')}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingSensorData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: appBarMenu(title: widget.jaula.nombre),
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos de la jaula...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Breadcrumb de navegación
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                    color: Color(0xFF8B4513),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Mis Animales',
                                    style: TextStyle(
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              ' > ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              widget.jaula.nombre,
                              style: const TextStyle(
                                color: Color(0xFF8B4513),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Información básica de la jaula
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B4513)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.home_work,
                                        color: Color(0xFF8B4513),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.jaula.nombre,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8B4513),
                                            ),
                                          ),
                                          Text(
                                            widget.jaula.descripcion,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                FutureBuilder<List<animal_svc.AnimalModel>>(
                                  future: _animalsFuture,
                                  builder: (context, snapshot) {
                                    final cantidadCuyes =
                                        snapshot.data?.length ?? 0;
                                    // Fix division by zero: check if capacidadMaxima > 0
                                    final porcentajeOcupacion =
                                        widget.jaula.capacidadMaxima > 0
                                            ? (cantidadCuyes /
                                                    widget
                                                        .jaula.capacidadMaxima *
                                                    100)
                                                .round()
                                            : 0;

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            'Cuyes',
                                            '$cantidadCuyes/${widget.jaula.capacidadMaxima}',
                                            Icons.pets,
                                            porcentajeOcupacion > 80
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Ocupación',
                                            '$porcentajeOcupacion%',
                                            Icons.analytics,
                                            porcentajeOcupacion > 80
                                                ? Colors.red
                                                : Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Creada',
                                            _formatDate(
                                                widget.jaula.fechaCreacion),
                                            Icons.calendar_today,
                                            Colors.orange,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Sección IoT
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.sensors,
                                        color: Color(0xFF2196F3),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Monitoreo IoT',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B4513),
                                        ),
                                      ),
                                    ),
                                    // Manual refresh button
                                    IconButton(
                                      onPressed: _isRefreshingSensorData
                                          ? null
                                          : _refreshSensorData,
                                      icon: _isRefreshingSensorData
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Color(0xFF2196F3)),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.refresh,
                                              size: 18,
                                              color: Color(0xFF2196F3),
                                            ),
                                      tooltip: _isRefreshingSensorData
                                          ? 'Actualizando...'
                                          : 'Actualizar datos',
                                      padding: const EdgeInsets.all(2),
                                      constraints: const BoxConstraints(
                                        minWidth: 28,
                                        minHeight: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Real-time connection status
                                    _buildConnectionStatus(),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Status indicator row
                                Row(
                                  children: [
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getJaulaStatus()['color'],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getJaulaStatus()['icon'],
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getJaulaStatus()['text'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Show last update indicator
                                _buildUpdateIndicator(),

                                // Sensores principales con datos reales
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildIoTCard(
                                        'Agua',
                                        '${_getWaterLevel().toStringAsFixed(1)}ml',
                                        Icons.water_drop,
                                        _getWaterStatus()['color'],
                                        _getWaterStatus()['status'],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildIoTCard(
                                        'Temperatura',
                                        '${_getTemperature().toStringAsFixed(1)}°C',
                                        Icons.thermostat,
                                        _getTemperatureStatus()['color'],
                                        _getTemperatureStatus()['status'],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildIoTCard(
                                        'CO2',
                                        '${_getCO2Level().toStringAsFixed(0)} ppm',
                                        Icons.air,
                                        _getCO2Status()['color'],
                                        _getCO2Status()['status'],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildIoTCard(
                                        'Humedad',
                                        '${_getHumidity().toStringAsFixed(1)}%',
                                        Icons.opacity,
                                        _getHumidityStatus()['color'],
                                        _getHumidityStatus()['status'],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildIoTCard(
                                        'Limpieza',
                                        '${_getDaysToClean()} días',
                                        Icons.cleaning_services,
                                        _getDaysToClean() > 2
                                            ? Colors.green
                                            : Colors.red,
                                        _getDaysToClean() > 2
                                            ? 'Programada'
                                            : 'Urgente',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildIoTCard(
                                        'Última limpieza',
                                        _getLastCleaningDate(),
                                        Icons.history,
                                        _getDaysToClean() > 2
                                            ? Colors.grey
                                            : Colors.orange,
                                        _getDaysToClean() > 2
                                            ? 'Reciente'
                                            : 'Hace tiempo',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Estado de dispositivos IoT
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF2196F3)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.device_hub,
                                            color: Color(0xFF2196F3),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Estado de Dispositivos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2196F3),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDeviceStatusGrid(),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                    height: 16), // Horarios de comida
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9800)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFFF9800)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            color: Color(0xFFFF9800),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Horarios de Alimentación',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF9800),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF9800),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_getFeedingSchedules().length} comidas/día',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFeedingScheduleList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Header de cuyes
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cuyes en esta jaula',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _navigateToAddCuy(),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Agregar Cuy',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B4513),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Lista de cuyes
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 400,
                        child: FutureBuilder<List<animal_svc.AnimalModel>>(
                          future: _animalsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error,
                                        size: 64, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text('Error: ${snapshot.error}'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadAnimals,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No hay cuyes en esta jaula',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Agrega el primer cuy para comenzar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final cuyes = snapshot.data!;
                            return ListView.builder(
                              itemCount: cuyes.length,
                              itemBuilder: (context, index) {
                                final cuy = cuyes[index];
                                return _buildAnimalCard(cuy);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 80), // Espacio para FAB
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCuy(),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Cuy'),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIoTCard(
      String title, String value, IconData icon, Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(animal_svc.AnimalModel animal) {
    Color estadoColor = _getEstadoColor(animal.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditAnimal(animal),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar del animal
              CircleAvatar(
                radius: 24,
                backgroundColor: estadoColor.withOpacity(0.2),
                child: Icon(
                  animal.sexo == 'macho' ? Icons.male : Icons.female,
                  color: estadoColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            animal.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            animal.estado.toUpperCase(),
                            style: TextStyle(
                              color: estadoColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.palette, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          animal.color,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.monitor_weight,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${animal.peso} kg',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Edad: ${animal.edadFormateada}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Menú de acciones
              PopupMenuButton<String>(
                onSelected: (value) => _handleAnimalAction(value, animal),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Ver detalles'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
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

  /// Build real-time connection status indicator
  Widget _buildConnectionStatus() {
    final isConnected = _latestSensorData != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            isConnected ? 'Live' : 'Off',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// Get formatted last update time
  String _getLastUpdateTime() {
    if (_lastSensorUpdateTime == null) {
      return 'Sin datos';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastSensorUpdateTime!);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Hace ${difference.inHours}h';
    }
  }

  /// Show real-time update indicator
  Widget _buildUpdateIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.update,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            'Última actualización: ${_getLastUpdateTime()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos IoT para obtener datos reales de sensores
  Map<String, dynamic> _getJaulaStatus() {
    if (_latestSensorData == null || _currentRanges == null) {
      return {
        'color': Colors.grey,
        'icon': Icons.sensors_off,
        'text': 'Sin datos'
      };
    }

    final sensor = _latestSensorData!;
    final range = _currentRanges!;

    // Verificar si los valores están dentro de los rangos
    final violations = _acceptableRangeService.getRangeViolations(
      range: range,
      temperature: sensor.temperature,
      humidity: sensor.humidity,
      co2: sensor.co2,
      waterQuality: sensor.waterQuality,
      waterQuantity: sensor.waterQuantity,
    );

    if (violations.isEmpty) {
      return {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'text': 'Excelente'
      };
    } else if (violations.length <= 2) {
      return {'color': Colors.orange, 'icon': Icons.info, 'text': 'Regular'};
    } else {
      return {'color': Colors.red, 'icon': Icons.warning, 'text': 'Crítico'};
    }
  }

  double _getWaterLevel() {
    return _latestSensorData?.waterQuantity ?? 0.0;
  }

  double _getTemperature() {
    return _latestSensorData?.temperature ?? 0.0;
  }

  double _getCO2Level() {
    return _latestSensorData?.co2 ?? 0.0;
  }

  double _getHumidity() {
    return _latestSensorData?.humidity ?? 0.0;
  }

  Map<String, dynamic> _getWaterStatus() {
    final waterLevel = _getWaterLevel();
    if (_currentRanges != null) {
      final isInRange = _currentRanges!.isWaterQuantityInRange(waterLevel);
      return {
        'color': isInRange ? Colors.blue : Colors.red,
        'status': isInRange ? 'Buen estado' : 'Fuera de rango'
      };
    }
    return {
      'color': waterLevel > 500 ? Colors.blue : Colors.red,
      'status': waterLevel > 500 ? 'Buen estado' : 'Nivel bajo'
    };
  }

  Map<String, dynamic> _getTemperatureStatus() {
    final temperature = _getTemperature();
    if (_currentRanges != null) {
      final isInRange = _currentRanges!.isTemperatureInRange(temperature);
      return {
        'color': isInRange ? Colors.green : Colors.orange,
        'status': isInRange ? 'Óptima' : 'Fuera de rango'
      };
    }
    return {
      'color':
          temperature >= 18 && temperature <= 24 ? Colors.green : Colors.orange,
      'status': temperature >= 18 && temperature <= 24 ? 'Óptima' : 'Regular'
    };
  }

  Map<String, dynamic> _getCO2Status() {
    final co2 = _getCO2Level();
    if (_currentRanges != null) {
      final isInRange = _currentRanges!.isCo2InRange(co2);
      return {
        'color': isInRange ? Colors.green : Colors.red,
        'status': isInRange ? 'Normal' : 'Fuera de rango'
      };
    }
    return {
      'color': co2 < 1000 ? Colors.green : Colors.red,
      'status': co2 < 1000 ? 'Normal' : 'Alto'
    };
  }

  Map<String, dynamic> _getHumidityStatus() {
    final humidity = _getHumidity();
    if (_currentRanges != null) {
      final isInRange = _currentRanges!.isHumidityInRange(humidity);
      return {
        'color': isInRange ? Colors.blue : Colors.orange,
        'status': isInRange ? 'Ideal' : 'Fuera de rango'
      };
    }
    return {
      'color': humidity >= 40 && humidity <= 70 ? Colors.blue : Colors.orange,
      'status': humidity >= 40 && humidity <= 70 ? 'Ideal' : 'Regular'
    };
  }

  int _getDaysToClean() {
    // Simulación basada en fecha de creación de la jaula
    final daysSinceCreation =
        DateTime.now().difference(widget.jaula.fechaCreacion).inDays;
    return 7 - (daysSinceCreation % 7);
  }

  String _getLastCleaningDate() {
    final lastCleaning =
        DateTime.now().subtract(Duration(days: 7 - _getDaysToClean()));
    return _formatDate(lastCleaning);
  }

  List<String> _getFeedingSchedules() {
    if (_feedingSchedules.isEmpty) {
      return ['Sin horarios configurados'];
    }

    return _feedingSchedules.map((schedule) {
      return '${schedule.morningTime} - ${schedule.eveningTime}';
    }).toList();
  }

  Map<String, dynamic> _getDeviceStatus() {
    // Estado de dispositivos IoT
    return {
      'sensor_agua': _getWaterLevel() > 300,
      'sensor_temp': true,
      'sensor_co2': _getCO2Level() < 1200,
      'dispensador_comida': true,
      'sistema_limpieza': _getDaysToClean() > 0,
      'camara': widget.jaula.id % 2 == 0, // Algunas jaulas tienen cámara
    };
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'sano':
        return Colors.green;
      case 'enfermo':
        return Colors.red;
      case 'reproduccion':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddCuy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CuyFormScreen(
          jaulaId: widget.jaula.id,
          userId: widget.userId,
          fullname: widget.fullname,
          username: widget.username,
          photoUrl: widget.photoUrl,
          role: widget.role,
        ),
      ),
    ).then((_) => _loadAnimals());
  }

  void _navigateToEditAnimal(animal_svc.AnimalModel animal) {
    // TODO: Implement animal editing
    // For now, show details dialog
    _showAnimalDetailsDialog(animal);
  }

  void _handleAnimalAction(String action, animal_svc.AnimalModel animal) {
    switch (action) {
      case 'view':
        _showAnimalDetailsDialog(animal);
        break;
      case 'edit':
        _navigateToEditAnimal(animal);
        break;
      case 'delete':
        _showDeleteAnimalDialog(animal);
        break;
    }
  }

  void _showAnimalDetailsDialog(animal_svc.AnimalModel animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              animal.sexo == 'macho' ? Icons.male : Icons.female,
              color: _getEstadoColor(animal.estado),
            ),
            const SizedBox(width: 8),
            Text(animal.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Sexo', animal.sexo),
            _buildDetailRow('Raza', animal.color),
            _buildDetailRow('Peso', '${animal.peso} kg'),
            _buildDetailRow('Estado', animal.estado),
            _buildDetailRow('Edad', animal.edadFormateada),
            _buildDetailRow(
                'Fecha de nacimiento', _formatDate(animal.fechaNacimiento)),
            _buildDetailRow(
                'Fecha de ingreso', _formatDate(animal.fechaIngreso)),
            if (animal.observaciones != null &&
                animal.observaciones!.isNotEmpty)
              _buildDetailRow('Observaciones', animal.observaciones!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAnimalDialog(animal_svc.AnimalModel animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que quieres eliminar al animal "${animal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAnimal(animal);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteAnimal(animal_svc.AnimalModel animal) async {
    try {
      await _animalService.deleteAnimal(animal.id);
      _loadAnimals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Animal "${animal.name}" eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el animal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusGrid() {
    final deviceStatus = _getDeviceStatus();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDeviceChip(
            'Sensor Agua', deviceStatus['sensor_agua'], Icons.sensors),
        _buildDeviceChip(
            'Sensor Temp.', deviceStatus['sensor_temp'], Icons.thermostat),
        _buildDeviceChip('Sensor CO2', deviceStatus['sensor_co2'], Icons.air),
        _buildDeviceChip('Dispensador', deviceStatus['dispensador_comida'],
            Icons.restaurant),
        _buildDeviceChip('Sist. Limpieza', deviceStatus['sistema_limpieza'],
            Icons.cleaning_services),
        if (deviceStatus['camara'])
          _buildDeviceChip('Cámara', deviceStatus['camara'], Icons.videocam),
      ],
    );
  }

  Widget _buildDeviceChip(String name, bool isActive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.green[700] : Colors.red[700],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive ? Icons.check_circle : Icons.error,
            size: 12,
            color: isActive ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingScheduleList() {
    final schedules = _getFeedingSchedules();

    if (schedules.length == 1 && schedules[0] == 'Sin horarios configurados') {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'No hay horarios de alimentación configurados para esta jaula.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: schedules.asMap().entries.map((entry) {
        final index = entry.key;
        final timeRange = entry.value;
        final times = timeRange.split(' - ');
        final morningTime = times.isNotEmpty ? times[0] : '';
        final eveningTime = times.length > 1 ? times[1] : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFF9800).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 16,
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horario ${index + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    Text(
                      'Mañana: $morningTime | Tarde: $eveningTime',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
