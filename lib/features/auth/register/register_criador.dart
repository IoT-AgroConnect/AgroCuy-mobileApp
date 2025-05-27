import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../login/login.dart';
import '../welcome/welcome_screen.dart';

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
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  Future<void> _registrarCriador() async {
    if (_ubicacionController.text.isEmpty ||
        _fechaNacimientoController.text.isEmpty ||
        _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final fecha = _fechaNacimientoController.text.trim();
    final fechaRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!fechaRegex.hasMatch(fecha)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha debe tener el formato aaaa-mm-dd')),
      );
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
      final jsonBody = jsonEncode(body);
      print("📤 JSON enviado a /api/v1/advisors:");
      print(jsonBody);
      print(widget.token);
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/breeders'),
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
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(),
          ),
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
                  'Formulario - Criador',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A5A44),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInput(_ubicacionController, 'Ubicación (departamento)'),
                const SizedBox(height: 16),
                _buildInput(_fechaNacimientoController, 'Fecha de nacimiento'),
                const SizedBox(height: 16),
                _buildInput(_descripcionController, 'Descripción (cuéntanos sobre ti)', maxLines: 5),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _registrarCriador,
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