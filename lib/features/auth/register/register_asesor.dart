import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AsesorFormScreen extends StatefulWidget {
  final int userId;
  final String token;
  final String fullname;
  const AsesorFormScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.fullname,
  });

  @override
  State<AsesorFormScreen> createState() => _AsesorFormScreenState();
}

class _AsesorFormScreenState extends State<AsesorFormScreen> {
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _profesionController = TextEditingController();
  final TextEditingController _experienciaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  File? _fotoPerfil;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery
    , maxHeight: 300,
      maxWidth: 300,
      imageQuality: 70,);

    if (pickedFile != null) {
      setState(() {
        _fotoPerfil = File(pickedFile.path);
      });
    }
  }

  Future<void> _registrarAsesor() async {
    if (_ubicacionController.text.isEmpty ||
        _fechaNacimientoController.text.isEmpty ||
        _profesionController.text.isEmpty ||
        _experienciaController.text.isEmpty ||
        _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    // Validar formato de fecha
    final fecha = _fechaNacimientoController.text.trim();
    final fechaRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!fechaRegex.hasMatch(fecha)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha debe tener el formato aaaa-mm-dd')),
      );
      return;
    }

    final fotoName = _fotoPerfil != null ? _fotoPerfil!.path.split('/').last : "sin_foto.jpg";


    final body = {
      "fullname": widget.fullname,
      "location": _ubicacionController.text,
      "birthdate": _fechaNacimientoController.text,
      "description": _descripcionController.text,
      "occupation": _profesionController.text,
      "experience": int.tryParse(_experienciaController.text) ?? 0,
      "photo": fotoName,
      "rating": 0,
      "userId": widget.userId,
    };
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/advisors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro completado con éxito')),
        );
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Excepción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB16546),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AgroConnect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFDF6E4),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3B3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Formulario - Asesor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A5A44),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInput(_ubicacionController, 'Ubicación (departamento)')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput(_fechaNacimientoController, 'Fecha de nacimiento')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInput(_profesionController, 'Profesión')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput(_experienciaController, 'Años de experiencia')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildInput(_descripcionController, 'Descripción (cuéntanos sobre ti)', maxLines: 5),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Text('Foto de perfil', style: TextStyle(color: Color(0xFFB16546))),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF6E4),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _fotoPerfil != null
                                ? Image.file(_fotoPerfil!, fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _seleccionarImagen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB16546),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            child: const Text('Subir', style: TextStyle(color: Color(0xFFFDF6E4))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _registrarAsesor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB16546),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(fontSize: 18, color: Color(0xFFFDF6E4)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFF1DC),
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Color(0xFFB16546)),
      ),
    );
  }
}
