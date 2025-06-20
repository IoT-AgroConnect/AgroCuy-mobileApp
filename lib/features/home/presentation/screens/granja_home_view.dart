import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import '../../../resources/presentation/recursos_list_view.dart';
import '../../../expenses/presentation/gastos_list_view.dart';

class GranjaHomeView extends StatelessWidget {
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const GranjaHomeView({
    super.key,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'Mi Granja'),
      drawer: role == 'ROLE_BREEDER'
          ? UserDrawerBreeder(
              fullname: fullname,
              username: username.split('@').first,
              photoUrl: photoUrl,
              userId: userId,
              role: role,
            )
          : UserDrawerAdvisor(
              fullname: fullname,
              username: username.split('@').first,
              photoUrl: photoUrl,
              advisorId: userId,
            ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              context,
              title: "Gestión de recursos",
              subtitle: "¡Gestione los recursos de su granja aquí!",
              image: "lib/assets/images/saco.png",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecursosListView()),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildCard(
              context,
              title: "Gestión de Gastos",
              subtitle: "¡Gestione los gastos de su granja aquí!",
              image: "lib/assets/images/chanchito.png",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GastosListView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen cuadrada minimalista
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Contenido textual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Continuar"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
