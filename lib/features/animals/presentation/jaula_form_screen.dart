import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import 'package:agrocuy/infrastructure/services/cage_service.dart';
import 'package:agrocuy/infrastructure/services/session_service.dart';
import '../data/models/jaula_model.dart';

class JaulaFormScreen extends StatefulWidget {
  final JaulaModel? jaula; // null para crear, con datos para editar
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const JaulaFormScreen({
    super.key,
    this.jaula,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  });

  @override
  State<JaulaFormScreen> createState() => _JaulaFormScreenState();
}

class _JaulaFormScreenState extends State<JaulaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _capacidadController = TextEditingController();
  late final CageService _cageService;
  late final SessionService _sessionService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cageService = CageService();
    _sessionService = SessionService();

    if (widget.jaula != null) {
      _nombreController.text = widget.jaula!.nombre;
      _descripcionController.text = widget.jaula!.descripcion;
      _capacidadController.text = widget.jaula!.capacidadMaxima.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.jaula != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: appBarMenu(title: isEditing ? 'Editar Jaula' : 'Nueva Jaula'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb de navegación
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
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
                      isEditing
                          ? 'Editar ${widget.jaula!.nombre}'
                          : 'Nueva Jaula',
                      style: const TextStyle(
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Card(
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
                          Icon(
                            isEditing ? Icons.edit : Icons.add_circle,
                            color: const Color(0xFF8B4513),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing
                                ? 'Editar información de la jaula'
                                : 'Crear nueva jaula',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Campo Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la jaula',
                          hintText: 'Ej: Jaula A1, Reproductores, etc.',
                          prefixIcon: Icon(Icons.label),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          if (value.trim().length < 2) {
                            return 'El nombre debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Descripción
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe el propósito de esta jaula...',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Capacidad
                      TextFormField(
                        controller: _capacidadController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad máxima',
                          hintText: 'Número máximo de cuyes',
                          prefixIcon: Icon(Icons.numbers),
                          suffixText: 'cuyes',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La capacidad es obligatoria';
                          }
                          final capacidad = int.tryParse(value.trim());
                          if (capacidad == null) {
                            return 'Ingrese un número válido';
                          }
                          if (capacidad <= 0) {
                            return 'La capacidad debe ser mayor a 0';
                          }
                          if (capacidad > 100) {
                            return 'La capacidad no puede ser mayor a 100';
                          }
                          return null;
                        },
                      ),

                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Creada el ${_formatDate(widget.jaula!.fechaCreacion)}',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF8B4513)),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Color(0xFF8B4513)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveJaula,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEditing ? 'Actualizar' : 'Crear',
                              style: const TextStyle(color: Colors.white),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveJaula() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('DEBUG: Initializing session...');
      // Ensure session is initialized
      await _sessionService.init();

      print('DEBUG: Checking authentication...');
      final isAuth = await _cageService.isAuthenticated();
      print('DEBUG: isAuthenticated: $isAuth');

      if (!isAuth) {
        throw Exception(
            'Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      if (widget.jaula != null) {
        print('DEBUG: Updating existing cage...');
        // Update existing cage
        final updateRequest = UpdateCageRequest(
          name: _nombreController.text.trim(),
          observations: _descripcionController.text.trim(),
          size: int.parse(_capacidadController.text.trim()),
        );
        await _cageService.updateCage(widget.jaula!.id, updateRequest);
      } else {
        print('DEBUG: Creating new cage...');
        // Create new cage
        final createRequest = CreateCageRequest(
          name: _nombreController.text.trim(),
          observations: _descripcionController.text.trim(),
          size: int.parse(_capacidadController.text.trim()),
          breederId: widget.userId, // Use current user as breeder
        );
        print('DEBUG: CreateRequest: ${createRequest.toJson()}');
        await _cageService.createCage(createRequest);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.jaula != null
                  ? 'Jaula actualizada exitosamente'
                  : 'Jaula creada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('DEBUG: Error in _saveJaula: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la jaula: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
