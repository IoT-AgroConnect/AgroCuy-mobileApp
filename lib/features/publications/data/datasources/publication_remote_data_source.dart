import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../infrastructure/services/base_service.dart';
import '../models/publication_model.dart';

class PublicationRemoteDataSource extends BaseService {
  Future<List<PublicationModel>> getPublications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => PublicationModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener publicaciones: ${response.statusCode} ${response.body}');
    }
  }

  Future<PublicationModel> getPublicationById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return PublicationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener publicación');
    }
  }

  Future<void> createPublication(PublicationModel publication, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/publications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(publication.toCreateJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear publicación: ${response.body}');
    }
  }

  Future<void> updatePublication(int id, Map<String, dynamic> data, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/publications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar publicación: ${response.body}');
    }
  }

  Future<void> deletePublication(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/publications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar publicación');
    }
  }
}
