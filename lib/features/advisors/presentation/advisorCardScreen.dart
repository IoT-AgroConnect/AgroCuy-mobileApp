import 'package:flutter/material.dart';
import '../data/models/advisor_model.dart';
import 'advisorDetailScreen.dart';

class AdvisorCard extends StatelessWidget {
  final AdvisorModel advisor;

  const AdvisorCard({super.key, required this.advisor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: const Color(0xFFFFF4F1), // pastel suave
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📷 Imagen tipo banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: advisor.photo != null && advisor.photo!.isNotEmpty
                ? Image.network(
              advisor.photo!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/images/default_user.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisor.fullname ?? 'Nombre no disponible',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('Experiencia: ${advisor.experience} años'),
                const SizedBox(height: 4),
                Text('Ubicación: ${advisor.location}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text(advisor.rating?.toStringAsFixed(1) ?? '0.0'),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdvisorDetailScreen(advisor: advisor),
                        ),
                      );
                    },
                    child: const Text('+ información'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
