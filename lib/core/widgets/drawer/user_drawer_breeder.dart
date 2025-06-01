import 'package:flutter/material.dart';

import 'package:agrocuy/features/auth/presentation/login/login_screen.dart';

class UserDrawerBreeder extends StatelessWidget {
  final String fullname;
  final String username;
  final String photoUrl;

  const UserDrawerBreeder({
    super.key,
    required this.fullname,
    required this.username,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE4A46E),
      child: Column(
        children: [
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.menu, color: Colors.white),
            title: const Text("AgroCuy", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(photoUrl),
          ),
          const SizedBox(height: 10),
          Text(
            fullname,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          Text('@$username', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),
          ...[
            'Mi granja',
            'Asesores',
            'Mis Animales',
            'Publicaciones',
            'Notificaciones',
            'Calendario',
            'Configuración',
          ].map((item) => ListTile(
            title: Text(item, style: const TextStyle(color: Colors.white)),
            onTap: () {},
          )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
