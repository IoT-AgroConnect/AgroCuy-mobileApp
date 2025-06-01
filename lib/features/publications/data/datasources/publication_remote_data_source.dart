import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../infrastructure/services/base_service.dart';
import '../models/publication_model.dart';

class PublicationRemoteDataSource extends BaseService {
  Future<List<PublicationModel>> getPublications() async {
    final response = await http.get(Uri.parse('$baseUrl/publications'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => PublicationModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener publicaciones');
    }
  }

  Future<PublicationModel> getPublicationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/publications/$id'));
    if (response.statusCode == 200) {
      return PublicationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener publicación');
    }
  }

  Future<void> createPublication(PublicationModel publication) async {
    final response = await http.post(
      Uri.parse('$baseUrl/publications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(publication.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear publicación');
    }
  }

  Future<void> updatePublication(int id, PublicationModel publication) async {
    final response = await http.put(
      Uri.parse('$baseUrl/publications/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(publication.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar publicación');
    }
  }

  Future<void> deletePublication(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/publications/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar publicación');
    }
  }
}