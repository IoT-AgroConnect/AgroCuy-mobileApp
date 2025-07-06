import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import 'package:agrocuy/infrastructure/services/cage_service.dart';
import 'package:agrocuy/infrastructure/services/animal_service.dart'
    as animal_svc;
import 'package:agrocuy/infrastructure/services/session_service.dart';
import '../data/models/jaula_model.dart';
import 'jaula_detail_screen_iot.dart';
import 'jaula_form_screen.dart';

class AnimalsScreen extends StatefulWidget {
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const AnimalsScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  });

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late final CageService _cageService;
  late final animal_svc.AnimalService _animalService;
  late final SessionService _sessionService;
  late Future<List<JaulaModel>> _jaulasFuture;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cageService = CageService();
    _animalService = animal_svc.AnimalService();
    _sessionService = SessionService();
    _loadJaulas();
  }

  Future<void> _loadJaulas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('DEBUG AnimalsScreen: Starting _loadJaulas...');

      // Ensure session is initialized
      await _sessionService.init();
      print('DEBUG AnimalsScreen: SessionService initialized');

      // Check authentication with detailed logging
      final isAuth = await _cageService.isAuthenticated();
      print('DEBUG AnimalsScreen: isAuthenticated result: $isAuth');

      if (!isAuth) {
        throw Exception(
            'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      print('DEBUG AnimalsScreen: Authentication passed, fetching cages...');
      _jaulasFuture = _cageService.getCagesWithRetry();
      final jaulas = await _jaulasFuture; // Wait to catch any errors
      print(
          'DEBUG AnimalsScreen: Cages loaded successfully, count: ${jaulas.length}');
    } catch (e) {
      print('DEBUG AnimalsScreen: Error in _loadJaulas: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int> _getCantidadCuyesPorJaula(int jaulaId) async {
    try {
      print('DEBUG AnimalsScreen: Getting animals for cage $jaulaId');
      final animals = await _animalService.getAnimalsByCageIdWithRetry(jaulaId);
      print(
          'DEBUG AnimalsScreen: Animals fetched for cage $jaulaId, count: ${animals.length}');
      return animals.length;
    } catch (e) {
      print(
          'DEBUG AnimalsScreen: Error fetching animals for cage $jaulaId: $e');
      // Return 0 if error fetching animals
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'Mis Animales'),
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
        onRefresh: _loadJaulas,
        child: Column(
          children: [
            // Header con información
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jaulas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Toca una jaula para ver sus cuyes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAddJaula(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Nueva Jaula',
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
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
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

    return FutureBuilder<List<JaulaModel>>(
      future: _jaulasFuture,
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

        final jaulas = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: jaulas.length,
          itemBuilder: (context, index) {
            final jaula = jaulas[index];
            return FutureBuilder<int>(
              future: _getCantidadCuyesPorJaula(jaula.id),
              builder: (context, cuyesSnapshot) {
                final cantidadCuyes = cuyesSnapshot.data ?? 0;
                return _buildJaulaCard(jaula, cantidadCuyes);
              },
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
            'Error al cargar jaulas',
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
            onPressed: _loadJaulas,
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay jaulas registradas',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega tu primera jaula para comenzar',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildJaulaCard(JaulaModel jaula, int cantidadCuyes) {
    print(
        'DEBUG AnimalsScreen: Building card for jaula ${jaula.id}, cantidadCuyes: $cantidadCuyes, capacidadMaxima: ${jaula.capacidadMaxima}');

    // Ensure values are valid to avoid NaN or Infinity
    final validCantidadCuyes =
        cantidadCuyes.isNaN || cantidadCuyes.isInfinite ? 0 : cantidadCuyes;
    final validCapacidad =
        jaula.capacidadMaxima <= 0 ? 1 : jaula.capacidadMaxima;

    final porcentajeOcupacion =
        (validCantidadCuyes / validCapacidad * 100).round();

    print(
        'DEBUG AnimalsScreen: Calculated porcentajeOcupacion: $porcentajeOcupacion');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToJaulaDetail(jaula),
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
                      jaula.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleJaulaAction(value, jaula),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
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
              const SizedBox(height: 8),
              Text(
                jaula.descripcion,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.pets,
                      label: '$cantidadCuyes/${jaula.capacidadMaxima} cuyes',
                      color:
                          porcentajeOcupacion > 80 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.analytics,
                      label: '$porcentajeOcupacion% ocupación',
                      color:
                          porcentajeOcupacion > 80 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Creada: ${_formatDate(jaula.fechaCreacion)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToJaulaDetail(JaulaModel jaula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JaulaDetailScreen(
          jaula: jaula,
          userId: widget.userId,
          fullname: widget.fullname,
          username: widget.username,
          photoUrl: widget.photoUrl,
          role: widget.role,
        ),
      ),
    ).then((_) => _loadJaulas());
  }

  void _navigateToAddJaula() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JaulaFormScreen(
          userId: widget.userId,
          fullname: widget.fullname,
          username: widget.username,
          photoUrl: widget.photoUrl,
          role: widget.role,
        ),
      ),
    ).then((_) => _loadJaulas());
  }

  void _handleJaulaAction(String action, JaulaModel jaula) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JaulaFormScreen(
              jaula: jaula,
              userId: widget.userId,
              fullname: widget.fullname,
              username: widget.username,
              photoUrl: widget.photoUrl,
              role: widget.role,
            ),
          ),
        ).then((_) => _loadJaulas());
        break;
      case 'delete':
        _showDeleteDialog(jaula);
        break;
    }
  }

  void _showDeleteDialog(JaulaModel jaula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que quieres eliminar la jaula "${jaula.nombre}"?\n\nEsto también eliminará todos los cuyes que estén en esta jaula.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteJaula(jaula);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteJaula(JaulaModel jaula) async {
    try {
      final success = await _cageService.deleteCage(jaula.id);
      if (success) {
        _loadJaulas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jaula "${jaula.nombre}" eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('No se pudo eliminar la jaula');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la jaula: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
