import 'package:flutter/material.dart';
import 'package:agrocuy/features/auth/presentation/login/login_screen.dart';
import 'package:agrocuy/features/publications/presentation/publication_list_advisor_screen.dart';

class UserDrawerAdvisor extends StatelessWidget {
  final String fullname;
  final String username;
  final String photoUrl;
  final int advisorId;
  final String token;

  const UserDrawerAdvisor({
    super.key,
    required this.fullname,
    required this.username,
    required this.photoUrl,
    required this.advisorId,
    required this.token,
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
          Text(fullname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          Text('@$username', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),
          _buildItem("Clientes", () {}),
          _buildItem("Notificaciones", () {}),
          _buildItem("Mis Publicaciones", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicationListAdvisorScreen(
                  advisorId: advisorId,
                  token: token,
                  fullname: fullname,
                  username: username,
                  photoUrl: photoUrl,
                ),
              ),
            );
          }),
          _buildItem("Horarios", () {}),
          _buildItem("Calendario", () {}),
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
    );
  }
}
