import 'package:agrocuy/features/advisors/domain/repositories/advisor_fake_repository.dart';
import 'package:flutter/material.dart';
import '../data/datasources/advisor_remote_data_source.dart';
import '../data/models/advisor_model.dart';
import '../domain/repositories/advisor_repository.dart';
import 'advisorCardScreen.dart';

class AdvisorListScreen extends StatefulWidget {
  const AdvisorListScreen({super.key});

  @override
  State<AdvisorListScreen> createState() => _AdvisorListScreenState();
}

class _AdvisorListScreenState extends State<AdvisorListScreen> {
  late AdvisorRepository _repository;
  //late AdvisorFakeRepository _repository;
  late Future<List<AdvisorModel>> _advisors;

  @override
  void initState() {
    super.initState();
    _repository = AdvisorRepository(AdvisorRemoteDataSource());
    //_repository = AdvisorFakeRepository();
    _advisors = _repository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asesores')),
      body: FutureBuilder<List<AdvisorModel>>(
        future: _advisors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay asesores disponibles'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final advisor = snapshot.data![index];
              return AdvisorCard(advisor: advisor);
            },
          );
        },
      ),
    );
  }
}
