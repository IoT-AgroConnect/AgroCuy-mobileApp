import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:agrocuy/features/auth/presentation/welcome/welcome_screen.dart';
import 'package:agrocuy/infrastructure/services/base_service.dart';

class CriadorFormScreen extends StatefulWidget {
  final int userId;
  final String token;
  final String fullname;
  final String name;

  const CriadorFormScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.fullname,
    required this.name,
  });

  @override
  State<CriadorFormScreen> createState() => _CriadorFormScreenState();
}

class _CriadorFormScreenState extends State<CriadorFormScreen> {
  final service = BaseService();
  final _ubicacionController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _descripcionController = TextEditingController();

  Future<void> _registrarCriador() async {
    if (_ubicacionController.text.isEmpty ||
        _fechaNacimientoController.text.isEmpty ||
        _descripcionController.text.isEmpty) {
      showError('Completa todos los campos');
      return;
    }

    final fechaRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!fechaRegex.hasMatch(_fechaNacimientoController.text)) {
      showError('La fecha debe tener el formato aaaa-mm-dd');
      return;
    }

    final body = {
      "fullname": widget.name,
      "location": _ubicacionController.text,
      "birthdate": _fechaNacimientoController.text,
      "description": _descripcionController.text,
      "userId": widget.userId,
    };

    try {
      final response = await http.post(
        Uri.parse('${service.baseUrl}/breeders'),
        headers: service.getHeaders(widget.token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
      } else {
        showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      showError('Ocurrió un error inesperado');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                const Text('Formulario - Criador', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8A5A44))),
                const SizedBox(height: 20),
                _buildInput(_ubicacionController, 'Ubicación'),
                const SizedBox(height: 16),
                _buildInput(_fechaNacimientoController, 'Fecha de nacimiento'),
                const SizedBox(height: 16),
                _buildInput(_descripcionController, 'Descripción', maxLines: 5),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _registrarCriador,
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
