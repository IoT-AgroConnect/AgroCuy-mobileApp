import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/available_date_model.dart';

class ScheduleRemoteDataSource {
  final http.Client client;

  ScheduleRemoteDataSource({required this.client});

  Future<List<ScheduleModel>> getSchedulesByAdvisorId(int advisorId) async {
    final response = await client.get(
      Uri.parse('https://tuservidor.com/api/schedules?advisorId=$advisorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los horarios');
    }
  }
}
