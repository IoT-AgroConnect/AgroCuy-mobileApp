import 'package:agrocuy/features/calendar/presentation/screens/CalendarScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrocuy/features/auth/presentation/login/login_screen.dart';

import '../../../features/advisors/presentation/advisorListScreen.dart';
import '../../../features/home/presentation/screens/granja_home_view.dart';
import '../../../features/notifications/presentation/notificationFullScreen.dart';

class UserDrawerBreeder extends StatelessWidget {
  final String fullname;
  final String username;
  final String photoUrl;
  final int? userId;
  final String? role;

  const UserDrawerBreeder({
    super.key,
    required this.fullname,
    required this.username,
    required this.photoUrl,
    this.userId,
    this.role,
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
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          Text('@$username', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),

          // Opciones del menú
          ListTile(
            title:
                const Text('Mi granja', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GranjaHomeView(
                    userId: userId ?? 0,
                    fullname: fullname,
                    username: username,
                    photoUrl: photoUrl,
                    role: role ?? 'ROLE_BREEDER',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title:
                const Text('Asesores', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdvisorListScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Mis Animales',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Publicaciones',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Notificaciones',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationScreen(
                    userId: userId ?? 0,
                    fullname: fullname,
                    username: username,
                    photoUrl: photoUrl,
                    role: role ?? 'ROLE_BREEDER',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title:
                const Text('Calendario', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarScreen(
                    userId: userId ?? 0,
                    fullname: fullname,
                    username: username,
                    photoUrl: photoUrl,
                    role: role ?? 'ROLE_BREEDER',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Configuración',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
