import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrocuy/features/publications/data/models/publication_model.dart';
import 'package:agrocuy/features/publications/data/datasources/publication_remote_data_source.dart';
import 'package:agrocuy/features/publications/domain/repositories/publication_repository.dart';
import 'package:agrocuy/infrastructure/services/firebase_api.dart';

class PublicationFormScreen extends StatefulWidget {
  final int advisorId;
  final String token;
  final PublicationModel? publication;

  const PublicationFormScreen({
    super.key,
    required this.advisorId,
    required this.token,
    this.publication,
  });

  @override
  State<PublicationFormScreen> createState() => _PublicationFormScreenState();
}

class _PublicationFormScreenState extends State<PublicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PublicationRepository _repository;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _repository = PublicationRepository(PublicationRemoteDataSource());

    if (widget.publication != null) {
      _titleController.text = widget.publication!.title;
      _descriptionController.text = widget.publication!.description;
      _imageUrl = widget.publication!.image;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_imageFile != null) {
        _imageUrl = await FirebaseApi.uploadImage(_imageFile!);
        print("🔗 URL de imagen subida: $_imageUrl");
      }

      final newPublication = PublicationModel(
        id: widget.publication?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _imageUrl ?? '',
        date: DateTime.now().toIso8601String(),
        advisorId: widget.advisorId,
      );

      if (widget.publication == null) {
        await _repository.create(newPublication, widget.token);
      } else {
        await _repository.update(widget.publication!.id, newPublication, widget.token);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print("❌ Error al guardar publicación: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar publicación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.publication == null ? 'Nueva Publicación' : 'Editar Publicación'),
        backgroundColor: const Color(0xFFB16546),
      ),
      backgroundColor: const Color(0xFFFFE3B3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                _imageFile != null
                    ? Image.file(_imageFile!, height: 120)
                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                    ? Image.network(_imageUrl!, height: 120)
                    : const Text('No se ha seleccionado imagen'),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Seleccionar imagen'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB16546)),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
