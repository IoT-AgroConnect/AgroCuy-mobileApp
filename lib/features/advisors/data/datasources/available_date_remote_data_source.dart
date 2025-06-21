import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/available_date_model.dart';

class AvailableDateRemoteDataSource {
  final http.Client client;

  AvailableDateRemoteDataSource({required this.client});

  Future<List<AvailableDateModel>> getAvailableDatesByAdvisorId(int advisorId) async {
    final response = await client.get(
      Uri.parse('https://tuservidor.com/api/AvailableDates?advisorId=$advisorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((e) => AvailableDateModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los horarios');
    }
  }
}
