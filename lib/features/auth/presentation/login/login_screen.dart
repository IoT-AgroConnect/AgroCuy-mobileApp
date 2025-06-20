// login_screen.dart
import 'package:flutter/material.dart';
import 'package:agrocuy/features/home/presentation/screens/HomeScreen.dart';
import 'package:agrocuy/features/publications/presentation/publication_list_advisor_screen.dart';
import 'package:agrocuy/features/auth/presentation/register/register.dart';
import 'package:agrocuy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agrocuy/features/auth/domain/repositories/auth_repository.dart';
import '../../../../../../core/widgets/app_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final AuthRepository _authRepository = AuthRepository(AuthRemoteDataSource());

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un correo válido')),
      );
      return;
    }

    try {
      final loginData = await _authRepository.login(email, password);

      // Tomar el token y el userId del loginData
      final token = loginData['token'];
      final userId = loginData['id'];
      await SessionService().setToken(token);

      final userData = await _authRepository.getUserData(userId);
      final role = (userData['roles'] as List).first;

      // Guardar datos de sesión en SharedPreferences
      await SessionService().setToken(token);
      await SessionService().setUserId(userId);
      await SessionService().setRole(role);
      // Guardar datos de sesión en SharedPreferences

      final profileData = await _authRepository.getProfileByRole(role);
      final profileList = profileData['list'] as List;
      final profile = profileList.firstWhere((e) => e['userId'] == userId);

      final String photoUrl = profile['photo']?.isNotEmpty == true
          ? profile['photo']
          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8CZsCIaMAVpL2YPvh7JH0RSePTVKH7umsgw&s';

      if (role == 'ROLE_ADVISOR') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PublicationListAdvisorScreen(
              advisorId: profile['id'],
              fullname: profile['fullname'],
              username: userData['username'],
              photoUrl: photoUrl,
            ),
          ),
        );
      } else if (role == 'ROLE_BREEDER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userId: userId,
              breederId: profile['id'],
              fullname: profile['fullname'],
              username: userData['username'],
              photoUrl: photoUrl,
              role: role,
            ),
          ),
        );
      } else {
        throw Exception("Rol no soportado");
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas o error de conexión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const appBar(),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFDF6E4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A5A44),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    filled: true,
                    fillColor: Color(0xFFFDF6E4),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: const Color(0xFFFDF6E4),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF7A4E3A),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Se te olvidó la contraseña?',
                      style: TextStyle(color: Color(0xFF8A5A44)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB16546),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Acceder',
                    style: TextStyle(fontSize: 18, color: Color(0xFFFDF6E4)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    '¿No tienes una cuenta? Regístrate aquí',
                    style: TextStyle(color: Color(0xFF8A5A44)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
