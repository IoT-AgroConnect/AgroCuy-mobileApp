import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import '../data/models/jaula_model.dart';
import '../data/models/cuy_model.dart';
import '../data/repositories/animals_repository.dart';
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
  final AnimalsRepository _repository = AnimalsRepository();
  late Future<List<CuyModel>> _cuyesFuture;

  @override
  void initState() {
    super.initState();
    _loadCuyes();
  }

  void _loadCuyes() {
    setState(() {
      _cuyesFuture = _repository.getCuyesByJaulaId(widget.jaula.id);
    });
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
      body: Column(
        children: [
          // Breadcrumb de navegación
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Información de la jaula
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
                            color: const Color(0xFF8B4513).withOpacity(0.1),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                    FutureBuilder<List<CuyModel>>(
                      future: _cuyesFuture,
                      builder: (context, snapshot) {
                        final cantidadCuyes = snapshot.data?.length ?? 0;
                        final porcentajeOcupacion =
                            (cantidadCuyes / widget.jaula.capacidadMaxima * 100)
                                .round();

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
                                _formatDate(widget.jaula.fechaCreacion),
                                Icons.calendar_today,
                                Colors.purple,
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
          ), // Header de cuyes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cuyes en esta jaula',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Toca un cuy para ver más detalles',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
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
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de cuyes
          Expanded(
            child: FutureBuilder<List<CuyModel>>(
              future: _cuyesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCuyes,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay cuyes en esta jaula',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cuyes.length,
                  itemBuilder: (context, index) {
                    final cuy = cuyes[index];
                    return _buildCuyCard(cuy);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para regresar a todas las jaulas
          FloatingActionButton.extended(
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Ver todas las jaulas'),
            heroTag: "back_to_jaulas",
          ),
          const SizedBox(height: 16),
          // Botón para agregar cuy
          FloatingActionButton.extended(
            onPressed: () => _navigateToAddCuy(),
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Cuy'),
            heroTag: "add_cuy",
          ),
        ],
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

  Widget _buildCuyCard(CuyModel cuy) {
    Color estadoColor = _getEstadoColor(cuy.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditCuy(cuy),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar del cuy
              CircleAvatar(
                radius: 24,
                backgroundColor: estadoColor.withOpacity(0.2),
                child: Icon(
                  cuy.sexo == 'macho' ? Icons.male : Icons.female,
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
                            cuy.nombre,
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
                            cuy.estado.toUpperCase(),
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
                          cuy.color,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.monitor_weight,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${cuy.peso} kg',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Edad: ${cuy.edadFormateada}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Menú de acciones
              PopupMenuButton<String>(
                onSelected: (value) => _handleCuyAction(value, cuy),
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
    ).then((_) => _loadCuyes());
  }

  void _navigateToEditCuy(CuyModel cuy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CuyFormScreen(
          cuy: cuy,
          jaulaId: widget.jaula.id,
          userId: widget.userId,
          fullname: widget.fullname,
          username: widget.username,
          photoUrl: widget.photoUrl,
          role: widget.role,
        ),
      ),
    ).then((_) => _loadCuyes());
  }

  void _handleCuyAction(String action, CuyModel cuy) {
    switch (action) {
      case 'view':
        _showCuyDetailsDialog(cuy);
        break;
      case 'edit':
        _navigateToEditCuy(cuy);
        break;
      case 'delete':
        _showDeleteCuyDialog(cuy);
        break;
    }
  }

  void _showCuyDetailsDialog(CuyModel cuy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              cuy.sexo == 'macho' ? Icons.male : Icons.female,
              color: _getEstadoColor(cuy.estado),
            ),
            const SizedBox(width: 8),
            Text(cuy.nombre),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Sexo', cuy.sexo),
            _buildDetailRow('Color', cuy.color),
            _buildDetailRow('Peso', '${cuy.peso} kg'),
            _buildDetailRow('Estado', cuy.estado),
            _buildDetailRow('Edad', cuy.edadFormateada),
            _buildDetailRow(
                'Fecha de nacimiento', _formatDate(cuy.fechaNacimiento)),
            _buildDetailRow('Fecha de ingreso', _formatDate(cuy.fechaIngreso)),
            if (cuy.observaciones != null && cuy.observaciones!.isNotEmpty)
              _buildDetailRow('Observaciones', cuy.observaciones!),
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

  void _showDeleteCuyDialog(CuyModel cuy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que quieres eliminar al cuy "${cuy.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCuy(cuy);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteCuy(CuyModel cuy) async {
    try {
      await _repository.deleteCuy(cuy.id);
      _loadCuyes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cuy "${cuy.nombre}" eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el cuy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
