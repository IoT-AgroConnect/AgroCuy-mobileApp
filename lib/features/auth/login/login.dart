import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar.dart';
import 'package:http/http.dart' as http;
import '../../home/HomeScreen.dart';
import '../register/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un correo válido')),
      );
      return;
    }

    final body = jsonEncode({
      "username": email,
      "password": password,
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/authentication/sign-in'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['id'];

        final userResponse = await http.get(
          Uri.parse('http://10.0.2.2:8080/api/v1/users/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );
        final userData = jsonDecode(userResponse.body);
        final roles = userData['roles'];
        final role = roles.first; // ROLE_BREEDER o ROLE_ADVISOR

        final roleUrl = role == "ROLE_BREEDER"
            ? 'http://10.0.2.2:8080/api/v1/breeders'
            : 'http://10.0.2.2:8080/api/v1/advisors';

        final roleResponse = await http.get(Uri.parse(roleUrl),
            headers: {'Authorization': 'Bearer $token'});

        final roleList = jsonDecode(roleResponse.body) as List;
        final profile = roleList.firstWhere((e) => e['userId'] == userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              token: token,
              userId: userId,
              fullname: profile['fullname'],
              username: userData['username'],
              photoUrl: profile['photo'] != null && profile['photo'].toString().isNotEmpty
                  ? profile['photo']
                  : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8CZsCIaMAVpL2YPvh7JH0RSePTVKH7umsgw&s',
            ),
          ),
        );
      } else {
        print("${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión')),
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
                  style: TextStyle(fontSize: 18,color: Color(0xFFFDF6E4)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
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
