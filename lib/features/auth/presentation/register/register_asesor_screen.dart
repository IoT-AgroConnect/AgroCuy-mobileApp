import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:agrocuy/infrastructure/services/base_service.dart';
import 'package:agrocuy/infrastructure/services/firebase_api.dart';
import 'package:agrocuy/features/auth/presentation/welcome/welcome_screen.dart';

class AsesorFormScreen extends StatefulWidget {
  final int userId;
  final String token;
  final String fullname;
  final String name;

  const AsesorFormScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.fullname,
    required this.name,
  });

  @override
  State<AsesorFormScreen> createState() => _AsesorFormScreenState();
}

class _AsesorFormScreenState extends State<AsesorFormScreen> {
  final _service = BaseService(); // COMPOSICIÓN
  final _ubicacionController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _profesionController = TextEditingController();
  final _experienciaController = TextEditingController();
  final _descripcionController = TextEditingController();

  File? _fotoPerfil;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 300,
      maxWidth: 300,
      imageQuality: 70,
    );

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
      print('Completa todos los campos');
      return;
    }

    final fechaRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!fechaRegex.hasMatch(_fechaNacimientoController.text)) {
      print('La fecha debe tener el formato aaaa-mm-dd');
      return;
    }

    if (_fotoPerfil == null) {
      print('Selecciona una imagen de perfil');
      return;
    }

    try {
      final fotoUrl = await FirebaseApi.uploadImage(_fotoPerfil!);

      final body = {
        "fullname": widget.name,
        "location": _ubicacionController.text,
        "birthdate": _fechaNacimientoController.text,
        "description": _descripcionController.text,
        "occupation": _profesionController.text,
        "experience": int.tryParse(_experienciaController.text) ?? 0,
        "photo": fotoUrl,
        "rating": 0,
        "userId": widget.userId,
      };

      final response = await http.post(
        Uri.parse('${_service.baseUrl}/advisors'),
        headers: _service.getHeaders(widget.token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      } else {
        print('Error al registrar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error inesperado: $e');
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
        title: const Text('AgroConnect', style: TextStyle(color: Color(0xFFFDF6E4))),
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
                const Text('Formulario - Asesor', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8A5A44))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInput(_ubicacionController, 'Ubicación')),
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
                _buildInput(_descripcionController, 'Descripción', maxLines: 5),
                const SizedBox(height: 16),
                Column(
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Subir', style: TextStyle(color: Color(0xFFFDF6E4))),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _registrarAsesor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB16546),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Registrar', style: TextStyle(fontSize: 18, color: Color(0xFFFDF6E4))),
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
