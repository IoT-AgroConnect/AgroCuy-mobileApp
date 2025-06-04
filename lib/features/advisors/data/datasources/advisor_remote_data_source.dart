import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../infrastructure/services/base_service.dart';
import '../models/advisor_model.dart';

class AdvisorRemoteDataSource extends BaseService {
  Future<List<AdvisorModel>> getAdvisors(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/advisors'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => AdvisorModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener asesores: ${response.statusCode} ${response.body}');
    }
  }

  Future<AdvisorModel> getAdvisorById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/advisors/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return AdvisorModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener asesor por ID: ${response.statusCode} ${response.body}');
    }
  }
}
