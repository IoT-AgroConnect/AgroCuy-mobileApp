import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrocuy/features/publications/data/models/publication_model.dart';
import 'package:agrocuy/features/publications/data/datasources/publication_remote_data_source.dart';
import 'package:agrocuy/features/publications/domain/repositories/publication_repository.dart';

class PublicationDetailScreen extends StatefulWidget {
  final int id;
  final String token;

  const PublicationDetailScreen({
    super.key,
    required this.id,
    required this.token,
  });

  @override
  State<PublicationDetailScreen> createState() => _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationDetailScreen> {
  final PublicationRepository _repository = PublicationRepository(PublicationRemoteDataSource());
  PublicationModel? _publication;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final pub = await _repository.getById(widget.id, widget.token);
      setState(() {
        _publication = pub;
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar detalle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _publication == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pub = _publication!;
    final dateFormatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(pub.date));

    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB16546),
        title: const Text('Detalle de publicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      pub.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Subir foto'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Tips', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(
              pub.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(pub.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.orange),
                const SizedBox(width: 8),
                const Text("ElCarlitosTV"), // hardcoded, ideally should come from backend
                const Spacer(),
                Text("Publicado el $dateFormatted"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
