import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // For making HTTP requests
import '../../../../infrastructure/services/base_service.dart'; // Assuming this path for your BaseService
import '../models/advisor_model.dart'; // Import the AdvisorModel we created

/// A data source class responsible for interacting with the remote API
/// to perform CRUD operations on Advisor data.
/// It extends BaseService to inherit common configurations like baseUrl.
class AdvisorRemoteDataSource extends BaseService {
  /// Fetches a list of advisors from the API.
  ///
  /// Requires an authentication [token].
  /// Throws an [Exception] if the API call fails.
  Future<List<AdvisorModel>> getAdvisors(String token) async {
    // Construct the full URI for the advisors endpoint
    final response = await http.get(
      Uri.parse('$baseUrl/advisors'),
      headers: {
        'Authorization': 'Bearer $token', // Authorization header with bearer token
        'Content-Type': 'application/json', // Specify content type as JSON
      },
    );

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Decode the JSON response body into a dynamic list
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map each JSON object in the list to an AdvisorModel instance
      return jsonList.map((e) => AdvisorModel.fromJson(e)).toList();
    } else {
      // Throw an exception with details if the request was not successful
      throw Exception('Error al obtener asesores: ${response.statusCode} ${response.body}');
    }
  }

  /// Fetches a single advisor by their ID from the API.
  ///
  /// Requires the advisor's [id] and an authentication [token].
  /// Throws an [Exception] if the API call fails or the advisor is not found.
  Future<AdvisorModel> getAdvisorById(String id, String token) async {
    // Note: Assuming 'id' is a String based on typical API patterns for IDs.
    // If your API uses int IDs, change 'String id' to 'int id'.
    final response = await http.get(
      Uri.parse('$baseUrl/advisors/$id'), // Endpoint for a single advisor by ID
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Decode the JSON response body and parse it into an AdvisorModel
      return AdvisorModel.fromJson(jsonDecode(response.body));
    } else {
      // Throw an exception for unsuccessful responses
      throw Exception('Error al obtener asesor por ID: ${response.statusCode} ${response.body}');
    }
  }

  /// Creates a new advisor by sending their data to the API.
  ///
  /// Takes an [advisor] object and an authentication [token].
  /// Throws an [Exception] if the creation fails.
  Future<void> createAdvisor(AdvisorModel advisor, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/advisors'), // Endpoint for creating advisors
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(advisor.toJson()), // Encode the AdvisorModel to JSON
    );

    // Check for successful status codes (200 OK, 201 Created)
    if (response.statusCode != 200 && response.statusCode != 201) {
      // Throw an exception if the creation was not successful
      throw Exception('Error al crear asesor: ${response.statusCode} ${response.body}');
    }
  }

  /// Updates an existing advisor's data on the API.
  ///
  /// Requires the advisor's [id], a [data] map containing fields to update,
  /// and an authentication [token].
  /// Throws an [Exception] if the update fails.
  Future<void> updateAdvisor(String id, Map<String, dynamic> data, String token) async {
    // Note: Assuming 'id' is a String. Change to 'int id' if your API uses int IDs.
    final response = await http.put(
      Uri.parse('$baseUrl/advisors/$id'), // Endpoint for updating a specific advisor
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data), // Encode the update data map to JSON
    );

    // Check for successful status code (200 OK)
    if (response.statusCode != 200) {
      // Throw an exception if the update was not successful
      throw Exception('Error al actualizar asesor: ${response.statusCode} ${response.body}');
    }
  }

  /// Deletes an advisor from the API.
  ///
  /// Requires the advisor's [id] and an authentication [token].
  /// Throws an [Exception] if the deletion fails.
  Future<void> deleteAdvisor(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/advisors/$id'), // Endpoint for deleting a specific advisor
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar asesor: ${response.statusCode} ${response.body}');
    }
  }
}