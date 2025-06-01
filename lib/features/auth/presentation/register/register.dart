import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agrocuy/core/widgets/app_bar.dart';
import 'package:agrocuy/features/auth/presentation/register/register_asesor_screen.dart';
import 'package:agrocuy/features/auth/presentation/register/register_criador_screen.dart';
import 'package:agrocuy/features/auth/presentation/terms_conditions/terms_and_conditions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const appBar(),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFDF6E4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Regístrate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8A5A44),
                ),
              ),
              const SizedBox(height: 28),
              _buildInput(_nameController, 'Nombre completo'),
              const SizedBox(height: 16),
              _buildInput(_emailController, 'Correo electrónico'),
              const SizedBox(height: 16),
              _buildInput(_passwordController, 'Contraseña', isPassword: true),
              const SizedBox(height: 16),
              _buildInput(_confirmPasswordController, 'Confirmar contraseña', isPassword: true),
              const SizedBox(height: 24),

              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFB16546),
                  ),
                  const Text('Acepto los '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'términos y condiciones',
                      style: TextStyle(color: Color(0xFF8A5A44)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoleButton('Criador'),
                  _buildRoleButton('Asesor'),
                ],
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '¿Tienes una cuenta? Accede desde aquí',
                  style: TextStyle(color: Color(0xFF8A5A44)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFDF6E4),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRoleButton(String role) {
    return ElevatedButton(
      onPressed: () async {
        if (_nameController.text.isEmpty ||
            _emailController.text.isEmpty ||
            _passwordController.text.isEmpty ||
            _confirmPasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor completa todos los campos')),
          );
          return;
        }

        if (!_emailController.text.contains('@')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingresa un correo electrónico válido')),
          );
          return;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Las contraseñas no coinciden')),
          );
          return;
        }

        if (!_acceptedTerms) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes aceptar los términos y condiciones')),
          );
          return;
        }

        final String selectedRole = role == 'Criador' ? 'ROLE_BREEDER' : 'ROLE_ADVISOR';

        final registered = await registerUser(
          name: _nameController.text,
          username: _emailController.text,
          password: _passwordController.text,
          role: selectedRole,
        );

        if (registered) {
          final signInData = await signInUser(
            username: _emailController.text,
            password: _passwordController.text,
          );

          if (signInData != null) {
            final token = signInData['token'];
            final userId = signInData['id'];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => role == 'Criador'
                    ? CriadorFormScreen(userId: userId, token: token, fullname: _nameController.text, name: _nameController.text)
                    : AsesorFormScreen(userId: userId, token: token, fullname: _nameController.text, name: _nameController.text),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al iniciar sesión automáticamente')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al registrarse. Intenta nuevamente.')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8B388),
        foregroundColor: const Color(0xFF8A5A44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(role),
    );
  }

  Future<bool> registerUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/authentication/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "roles": [role],
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error en registro: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> signInUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/authentication/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "token": data["token"],
          "id": data["id"],
        };
      } else {
        debugPrint('Sign-in fallido: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Excepción en sign-in: $e');
      return null;
    }
  }
}
