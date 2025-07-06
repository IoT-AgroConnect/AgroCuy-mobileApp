// login_screen.dart
import 'package:flutter/material.dart';
import 'package:agrocuy/features/home/presentation/screens/HomeScreen.dart';
import 'package:agrocuy/features/publications/presentation/publication_list_advisor_screen.dart';
import 'package:agrocuy/features/auth/presentation/register/register.dart';
import 'package:agrocuy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agrocuy/features/auth/domain/repositories/auth_repository.dart';
import '../../../../../../core/widgets/app_bar.dart';

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
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG LOGIN: Starting login process...');
      print('DEBUG LOGIN: Email: $email');
      print('DEBUG LOGIN: Attempting connection to backend...');

      // Initialize SessionService first
      await SessionService().init();
      print('DEBUG LOGIN: SessionService initialized');

      print('DEBUG LOGIN: Calling authRepository.login...');
      final loginData = await _authRepository.login(email, password);
      print('DEBUG LOGIN: Login successful, data: $loginData');

      // Tomar el token y el userId del loginData
      final token = loginData['token'];
      final userId = loginData['id'];
      print('DEBUG LOGIN: Token received: ${token.substring(0, 50)}...');
      print('DEBUG LOGIN: User ID: $userId');

      await SessionService().setToken(token);
      print('DEBUG LOGIN: Token saved to session');

      final userData = await _authRepository.getUserData(userId);
      final role = (userData['roles'] as List).first;
      print('DEBUG LOGIN: User role: $role');

      // Guardar datos de sesión en SharedPreferences
      await SessionService().setUserId(userId);
      await SessionService().setRole(role);
      print('DEBUG LOGIN: Session data saved completely');

      // Verify token was saved correctly
      final savedToken = SessionService().getToken();
      print(
          'DEBUG LOGIN: Verification - saved token length: ${savedToken.length}');
      print('DEBUG LOGIN: Verification - tokens match: ${token == savedToken}');

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
        // Save the breederId for future use
        await SessionService().setBreederId(profile['id']);
        print('DEBUG LOGIN: Breeder ID saved: ${profile['id']}');

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

      String errorMessage = 'Error de conexión desconocido';

      // Analizar el tipo de error para mostrar mensaje específico
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage =
            'Credenciales incorrectas. Verifica tu email y contraseña.';
      } else if (e.toString().contains('404') ||
          e.toString().contains('Not Found')) {
        errorMessage =
            'Servicio no encontrado. El servidor no está disponible.';
      } else if (e.toString().contains('405') ||
          e.toString().contains('Method Not Allowed')) {
        errorMessage =
            'Método no permitido. Error en la configuración del servidor.';
      } else if (e.toString().contains('400') ||
          e.toString().contains('Bad Request')) {
        errorMessage =
            'Datos inválidos. Verifica el formato del email y contraseña.';
      } else if (e.toString().contains('403') ||
          e.toString().contains('Forbidden')) {
        errorMessage = 'Acceso denegado. Tu cuenta puede estar deshabilitada.';
      } else if (e.toString().contains('408') ||
          e.toString().contains('Timeout')) {
        errorMessage =
            'Tiempo de espera agotado. Revisa tu conexión a internet.';
      } else if (e.toString().contains('500') ||
          e.toString().contains('Internal Server Error')) {
        errorMessage = 'Error interno del servidor. Inténtalo más tarde.';
      } else if (e.toString().contains('502') ||
          e.toString().contains('Bad Gateway')) {
        errorMessage =
            'Error de conexión con el servidor. Inténtalo más tarde.';
      } else if (e.toString().contains('503') ||
          e.toString().contains('Service Unavailable')) {
        errorMessage =
            'Servicio no disponible temporalmente. Inténtalo más tarde.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        errorMessage =
            'Sin conexión a internet. Verifica tu red y vuelve a intentar.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Error en el formato de datos del servidor.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'Conexión muy lenta. Verifica tu internet e inténtalo de nuevo.';
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage =
            'Error de seguridad SSL. Problema con certificados del servidor.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage =
            'Conexión rechazada. El servidor está apagado o no accesible.';
      } else if (e.toString().contains('No route to host')) {
        errorMessage =
            'No se puede conectar al servidor. Verifica la URL del backend.';
      } else if (e.toString().toLowerCase().contains('credenciales')) {
        errorMessage = 'Email o contraseña incorrectos.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error de Login',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(errorMessage),
              SizedBox(height: 8),
              Text(
                'Detalles técnicos: ${e.toString()}',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: _login,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB16546),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Acceder',
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFFDF6E4)),
                        ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
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
