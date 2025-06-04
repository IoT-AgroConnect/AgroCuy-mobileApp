import 'package:flutter/material.dart';
import '../data/models/advisor_model.dart';
import '../data/models/review_model.dart'; // Asegúrate de tener esta clase
import '../data/datasources/advisor_remote_data_source.dart';
import '../domain/repositories/advisor_repository.dart';
import 'ScheduleBookingScreen.dart';

class AdvisorDetailScreen extends StatelessWidget {
  const AdvisorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int advisorId = ModalRoute.of(context)!.settings.arguments as int;
    final repository = AdvisorRepository(AdvisorRemoteDataSource());

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Asesor')),
      body: FutureBuilder<AdvisorModel>(
        future: repository.getById(advisorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el asesor'));
          }

          final advisor = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: advisor.photo != null
                      ? NetworkImage(advisor.photo!)
                      : const AssetImage('assets/images/default_user.png')
                  as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  advisor.fullname ?? 'Nombre no disponible',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(advisor.occupation),
                const SizedBox(height: 8),
                Text(advisor.location),
                const SizedBox(height: 8),
                Text('Años de experiencia: ${advisor.experience}'),
                const SizedBox(height: 8),
                Text('Fecha de nacimiento: ${advisor.birthdate?.toLocal().toString().split(' ')[0] ?? "No disponible"}'),
                const SizedBox(height: 16),
                Text(advisor.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${advisor.rating ?? 0.0}'),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final scheduleRepository = ScheduleRepositoryImpl(); // Asegúrate de importar esto
                    final advisorSchedules = await scheduleRepository.getSchedulesByAdvisor(advisor.id);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScheduleBookingScreen(schedules: advisorSchedules),
                        ),
                      );
                    }
                  },
                  child: const Text("Reservar Cita"),
                ),

                const SizedBox(height: 32),
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
                      title: Text('Review'),
                      //title: Text(review.userId ?? 'Usuario'),
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
          );
        },
      ),
    );
  }
}
