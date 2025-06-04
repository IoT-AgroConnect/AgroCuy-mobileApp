import 'package:flutter/material.dart';
import '../data/datasources/advisor_remote_data_source.dart';
import '../data/models/advisor_model.dart';
import '../domain/repositories/advisor_repository.dart';

class AdvisorDetailScreen extends StatelessWidget {
  const AdvisorDetailScreen({super.key, required this.advisorId});
  final int advisorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Asesor')),
      body: FutureBuilder<AdvisorModel>(
        future: AdvisorRepository(AdvisorRemoteDataSource()).getById(advisorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el asesor'));
          }

          final advisor = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${advisor.fullname} ',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Experience: ${advisor.experience}'),
                const SizedBox(height: 8),
                Text('Especialidad: ${advisor.occupation}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
