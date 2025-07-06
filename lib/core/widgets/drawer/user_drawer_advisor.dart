import 'package:flutter/material.dart';
import 'package:agrocuy/features/auth/presentation/login/login_screen.dart';
import 'package:agrocuy/features/publications/presentation/publication_list_advisor_screen.dart';
import 'package:agrocuy/features/calendar/presentation/screens/CalendarScreenAdvisor.dart';
import 'package:agrocuy/features/schedules/presentation/ScheduleScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrocuy/features/home/presentation/screens/granja_home_view.dart';


class UserDrawerAdvisor extends StatelessWidget {
  final String fullname;
  final String username;
  final String photoUrl;
  final int advisorId;

  const UserDrawerAdvisor({
    super.key,
    required this.fullname,
    required this.username,
    required this.photoUrl,
    required this.advisorId,
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
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(photoUrl)),
          const SizedBox(height: 10),
          Text(fullname,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white)),
          Text('@${username.split('@').first}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),
          //solo estoy agregando esto para redirigir a la pantalla de mi granjae
          //_buildItem("Mi granja", () {
          //  Navigator.pop(context); //  CIERRA el Drawer
          //  Navigator.push(
          //    context,
          //    MaterialPageRoute(builder: (_) => const GranjaHomeView()),
          //  );
        //  }),
          //solo estoy agregando esto para redirigir a la pantalla de mi granja
          _buildItem("Clientes", () {}),
          _buildItem("Notificaciones", () {}),
          _buildItem("Mis Publicaciones", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicationListAdvisorScreen(
                  advisorId: advisorId,
                  fullname: fullname,
                  username: username,
                  photoUrl: photoUrl,
                ),
              ),
            );
          }),
          _buildItem("Horarios", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleScreen(
                  advisorId: advisorId,
                  fullname: fullname,
                  username: username,
                  photoUrl: photoUrl,
                ),
              ),
            );
          }),
          _buildItem("Calendario", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CalendarScreenAdvisor(
                  advisorId: advisorId,
                  fullname: fullname,
                  username: username,
                  photoUrl: photoUrl,
                ),
              ),
            );
          }),
          const Spacer(),
          _logoutButton(context),
        ],
      ),
    );
  }

  ListTile _buildItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        child:
            const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
