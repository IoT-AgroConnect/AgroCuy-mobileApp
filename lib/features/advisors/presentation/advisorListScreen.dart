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
  late Future<List<AdvisorModel>> _advisorsFuture;
  List<AdvisorModel> _allAdvisors = [];
  List<AdvisorModel> _filteredAdvisors = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = AdvisorRepository(AdvisorRemoteDataSource());
    _advisorsFuture = _loadAdvisors();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<AdvisorModel>> _loadAdvisors() async {
    final advisors = await _repository.getAll();
    setState(() {
      _allAdvisors = advisors;
      _filteredAdvisors = advisors;
    });
    return advisors;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAdvisors = _allAdvisors.where((advisor) {
        return advisor.fullname?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asesores')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar asesor',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AdvisorModel>>(
              future: _advisorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (_filteredAdvisors.isEmpty) {
                  return const Center(child: Text('No se encontraron asesores'));
                }

                return ListView.builder(
                  itemCount: _filteredAdvisors.length,
                  itemBuilder: (context, index) {
                    final advisor = _filteredAdvisors[index];
                    return AdvisorCard(advisor: advisor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
