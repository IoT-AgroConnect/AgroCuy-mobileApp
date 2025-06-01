import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';

class HomeScreen extends StatelessWidget {
  final String token;
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role; // NUEVO

  const HomeScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role, required breederId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'AgroCuy'),
      drawer: role == 'ROLE_BREEDER'
          ? UserDrawerBreeder(
        fullname: fullname,
        username: username.split('@').first,
        photoUrl: photoUrl,
      )
          : UserDrawerAdvisor(
        fullname: fullname,
        username: username.split('@').first,
        photoUrl: photoUrl,
        advisorId: userId, // Agregado
        token: token,      // Agregado
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryButton('Tips', const Color(0xFFE6EBA6), () {
                print('Tips seleccionado');
              }),
              const SizedBox(width: 10),
              _buildCategoryButton('Receta', const Color(0xFFFFE082), () {
                print('Receta seleccionada');
              }),
              const SizedBox(width: 10),
              _buildCategoryButton('Otros', const Color(0xFFCCE5FF), () {
                print('Otros seleccionado');
              }),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(6, (index) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://example.com/image$index.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ['Claudia23', 'Tilin001', 'EstebanQuito', 'ElCarlitosTV', 'ElzaPayo', 'TaniaCavia'][index],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
