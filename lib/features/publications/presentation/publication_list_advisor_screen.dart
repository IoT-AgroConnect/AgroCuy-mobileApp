import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:agrocuy/features/publications/data/models/publication_model.dart';
import 'package:agrocuy/features/publications/data/datasources/publication_remote_data_source.dart';
import 'package:agrocuy/features/publications/domain/repositories/publication_repository.dart';

import 'package:agrocuy/features/publications/presentation/PublicationDetailScreen.dart';
import 'package:agrocuy/features/publications/presentation/PublicationFormScreen.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';

class PublicationListAdvisorScreen extends StatefulWidget {
  final int advisorId;
  final String fullname;
  final String username;
  final String photoUrl;

  const PublicationListAdvisorScreen({
    super.key,
    required this.advisorId,
    required this.fullname,
    required this.username,
    required this.photoUrl,
  });

  @override
  State<PublicationListAdvisorScreen> createState() =>
      _PublicationListAdvisorScreenState();
}

class _PublicationListAdvisorScreenState
    extends State<PublicationListAdvisorScreen> {
  final PublicationRepository _repository =
  PublicationRepository(PublicationRemoteDataSource());

  List<PublicationModel> _publications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPublications();
  }

  Future<void> _loadPublications() async {
    try {
      final all = await _repository.getAll();
      setState(() {
        _publications =
            all.where((p) => p.advisorId == widget.advisorId).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar publicaciones: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePublication(int id) async {
    try {
      await _repository.delete(id);
      await _loadPublications();
    } catch (e) {
      print('Error al eliminar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar publicación')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      drawer: UserDrawerAdvisor(
        advisorId: widget.advisorId,
        fullname: widget.fullname,
        username: widget.username,
        photoUrl: widget.photoUrl,
      ),
      appBar: AppBar(
        title: const Text('Publicaciones - Mosaico'),
        backgroundColor: const Color(0xFFB16546),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: 'Filtrar',
                  items: const [
                    DropdownMenuItem(
                        value: 'Filtrar', child: Text('Filtrar')),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _publications.isEmpty
                  ? const Center(
                child: Text(
                  'No tienes publicaciones aún',
                  style: TextStyle(
                      fontSize: 16, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: _publications.length,
                itemBuilder: (context, index) {
                  final pub = _publications[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: pub.image.isNotEmpty
                          ? Image.network(
                        pub.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error,
                            stackTrace) =>
                        const Icon(Icons
                            .image_not_supported),
                      )
                          : const Icon(
                          Icons.image_not_supported),
                      title: Text(pub.title),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(pub.date)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            _deletePublication(pub.id),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicationDetailScreen(
                            id: pub.id
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicationFormScreen(
                      advisorId: widget.advisorId
                    ),
                  ),
                );
                if (result == true) _loadPublications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB16546),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
              ),
              child: const Text('Agregar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
