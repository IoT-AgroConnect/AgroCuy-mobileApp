class BaseService {
  String get baseUrl => 'http://web-services-main-production.up.railway.app/api/v1';

  Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}