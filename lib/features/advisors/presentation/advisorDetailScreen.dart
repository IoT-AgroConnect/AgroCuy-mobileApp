import 'package:flutter/material.dart';
import '../data/models/advisor_model.dart';

class AdvisorDetailScreen extends StatelessWidget {
  final AdvisorModel advisor;

  const AdvisorDetailScreen({super.key, required this.advisor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(advisor.fullname ?? 'Detalle del Asesor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📷 Imagen grande tipo banner o circular
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: advisor.photo != null && advisor.photo!.isNotEmpty
                  ? Image.network(
                advisor.photo!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/images/default_user.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // 🧑 Nombre y ocupación
            Text(
              advisor.fullname ?? 'Nombre no disponible',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(advisor.occupation, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Ubicación: ${advisor.location}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Experiencia: ${advisor.experience} años', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Nacimiento: ${advisor.birthdate?.toLocal().toString().split(' ')[0] ?? "No disponible"}'),
            const SizedBox(height: 20),

            // 📝 Descripción
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Descripción:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            Text(advisor.description),
            const SizedBox(height: 20),

            // ⭐ Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${advisor.rating?.toStringAsFixed(1) ?? '0.0'}'),
              ],
            ),
            const SizedBox(height: 24),

            // 📅 Botón para reservar cita
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/available-dates',
                  arguments: advisor.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reservar Cita'),
            ),

            const SizedBox(height: 32),

            // 💬 Reseñas
            if (advisor.reviews != null && advisor.reviews!.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reseñas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ...advisor.reviews!.map((review) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: const Text('Review'),
                  subtitle: Text(review.content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      review.rating.round(),
                          (index) => const Icon(Icons.star, size: 16, color: Colors.amber),
                    ),
                  ),
                ),
              )),
            ] else
              const Text('Este asesor aún no tiene reseñas.'),
          ],
        ),
      ),
    );
  }
}
