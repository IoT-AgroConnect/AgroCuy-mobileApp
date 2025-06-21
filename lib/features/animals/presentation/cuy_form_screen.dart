import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import '../data/models/cuy_model.dart';
import '../data/repositories/animals_repository.dart';

class CuyFormScreen extends StatefulWidget {
  final CuyModel? cuy; // null para crear, con datos para editar
  final int jaulaId;
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const CuyFormScreen({
    super.key,
    this.cuy,
    required this.jaulaId,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  });

  @override
  State<CuyFormScreen> createState() => _CuyFormScreenState();
}

class _CuyFormScreenState extends State<CuyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _pesoController = TextEditingController();
  final _colorController = TextEditingController();
  final _observacionesController = TextEditingController();
  final AnimalsRepository _repository = AnimalsRepository();

  String _sexoSeleccionado = 'macho';
  String _estadoSeleccionado = 'sano';
  DateTime _fechaNacimiento = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaIngreso = DateTime.now();
  bool _isLoading = false;

  final List<String> _sexos = ['macho', 'hembra'];
  final List<String> _estados = ['sano', 'enfermo', 'reproduccion'];
  final List<String> _coloresComunes = [
    'blanco',
    'negro',
    'marron',
    'gris',
    'tricolor',
    'blanco y negro',
    'marron y blanco',
    'otro'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cuy != null) {
      _nombreController.text = widget.cuy!.nombre;
      _pesoController.text = widget.cuy!.peso.toString();
      _colorController.text = widget.cuy!.color;
      _observacionesController.text = widget.cuy!.observaciones ?? '';
      _sexoSeleccionado = widget.cuy!.sexo;
      _estadoSeleccionado = widget.cuy!.estado;
      _fechaNacimiento = widget.cuy!.fechaNacimiento;
      _fechaIngreso = widget.cuy!.fechaIngreso;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _pesoController.dispose();
    _colorController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cuy != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: appBarMenu(title: isEditing ? 'Editar Cuy' : 'Nuevo Cuy'),
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
                            'Regresar a jaula',
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
                      isEditing ? 'Editar ${widget.cuy!.nombre}' : 'Nuevo Cuy',
                      style: const TextStyle(
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Información básica
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
                            isEditing ? Icons.edit : Icons.pets,
                            color: const Color(0xFF8B4513),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Información básica',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del cuy',
                          hintText: 'Ej: Pepe, Luna, Rocky...',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sexo y Estado en una fila
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _sexoSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Sexo',
                                prefixIcon: Icon(Icons.wc),
                                border: OutlineInputBorder(),
                              ),
                              items: _sexos.map((sexo) {
                                return DropdownMenuItem(
                                  value: sexo,
                                  child: Row(
                                    children: [
                                      Icon(
                                        sexo == 'macho'
                                            ? Icons.male
                                            : Icons.female,
                                        color: sexo == 'macho'
                                            ? Colors.blue
                                            : Colors.pink,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(sexo.toUpperCase()),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _sexoSeleccionado = value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _estadoSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                prefixIcon: Icon(Icons.health_and_safety),
                                border: OutlineInputBorder(),
                              ),
                              items: _estados.map((estado) {
                                Color color = estado == 'sano'
                                    ? Colors.green
                                    : estado == 'enfermo'
                                        ? Colors.red
                                        : Colors.purple;
                                return DropdownMenuItem(
                                  value: estado,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(estado.toUpperCase()),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _estadoSeleccionado = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Características físicas
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
                      const Row(
                        children: [
                          Icon(Icons.palette,
                              color: Color(0xFF8B4513), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Características físicas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Color
                      DropdownButtonFormField<String>(
                        value: _coloresComunes.contains(_colorController.text)
                            ? _colorController.text
                            : 'otro',
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          prefixIcon: Icon(Icons.color_lens),
                          border: OutlineInputBorder(),
                        ),
                        items: _coloresComunes.map((color) {
                          return DropdownMenuItem(
                            value: color,
                            child: Text(color.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == 'otro') {
                            _colorController.clear();
                          } else {
                            _colorController.text = value!;
                          }
                        },
                      ),

                      // Campo de texto para color personalizado
                      if (!_coloresComunes.contains(_colorController.text) ||
                          _colorController.text.isEmpty) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _colorController,
                          decoration: const InputDecoration(
                            labelText: 'Color personalizado',
                            hintText: 'Describe el color del cuy',
                            prefixIcon: Icon(Icons.brush),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El color es obligatorio';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Peso
                      TextFormField(
                        controller: _pesoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Peso',
                          hintText: '0.5',
                          prefixIcon: Icon(Icons.monitor_weight),
                          suffixText: 'kg',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El peso es obligatorio';
                          }
                          final peso = double.tryParse(value.trim());
                          if (peso == null) {
                            return 'Ingrese un peso válido';
                          }
                          if (peso <= 0 || peso > 5) {
                            return 'El peso debe estar entre 0.1 y 5 kg';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Fechas
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
                      const Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Color(0xFF8B4513), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Información temporal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cake),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fecha de nacimiento',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(_fechaNacimiento),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Fecha de ingreso
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.login),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fecha de ingreso a la jaula',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(_fechaIngreso),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Observaciones
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
                      const Row(
                        children: [
                          Icon(Icons.notes, color: Color(0xFF8B4513), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Observaciones adicionales',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _observacionesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Notas adicionales sobre el cuy (opcional)...',
                          border: OutlineInputBorder(),
                        ),
                      ),
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
                      onPressed: _isLoading ? null : _saveCuy,
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

  Future<void> _selectDate(BuildContext context, bool isNacimiento) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNacimiento ? _fechaNacimiento : _fechaIngreso,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isNacimiento) {
          _fechaNacimiento = picked;
        } else {
          _fechaIngreso = picked;
        }
      });
    }
  }

  void _saveCuy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cuy = CuyModel(
        id: widget.cuy?.id ?? 0, // El repository asignará el ID real
        nombre: _nombreController.text.trim(),
        sexo: _sexoSeleccionado,
        fechaNacimiento: _fechaNacimiento,
        peso: double.parse(_pesoController.text.trim()),
        color: _colorController.text.trim(),
        estado: _estadoSeleccionado,
        jaulaId: widget.jaulaId,
        fechaIngreso: _fechaIngreso,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      );

      if (widget.cuy != null) {
        await _repository.updateCuy(cuy);
      } else {
        await _repository.createCuy(cuy);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cuy != null
                  ? 'Cuy actualizado exitosamente'
                  : 'Cuy creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el cuy: $e'),
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
