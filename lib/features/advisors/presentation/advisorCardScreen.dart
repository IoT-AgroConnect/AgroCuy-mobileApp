import 'package:flutter/material.dart';
import '../data/models/advisor_model.dart';

class AdvisorCard extends StatelessWidget {
  final AdvisorModel advisor;

  const AdvisorCard({super.key, required this.advisor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: advisor.photo != null && advisor.photo!.isNotEmpty
              ? NetworkImage(advisor.photo!)
              : const AssetImage('assets/images/default_user.png') as ImageProvider,
        ),
        title: Text(advisor.fullname ?? 'Nombre no disponible'),
        subtitle: Text(advisor.description),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/advisor-detail',
            arguments: advisor, // Pasamos el advisor completo
          );
        },
      ),
    );
  }
}
