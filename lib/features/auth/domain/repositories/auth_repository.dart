import 'package:agrocuy/features/auth/data/datasources/auth_remote_data_source.dart';

// Shared imports
import '../../../../infrastructure/services/session_service.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionService _session = SessionService();

  AuthRepository(this.remoteDataSource);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  Future<Map<String, dynamic>> getUserData(int userId) async {
    final token = _session.getToken();
    return await remoteDataSource.getUserData(token, userId);
  }

  Future<Map<String, dynamic>> getProfileByRole(String role) async {
    final token = _session.getToken();
    return await remoteDataSource.getProfileByRole(token, role);
  }

  Future<bool> registerUser({
    required String username,
    required String password,
    required String role,
  }) async {
    return await remoteDataSource.registerUser(
      username: username,
      password: password,
      role: role,
    );
  }

  Future<Map<String, dynamic>?> signInUser({
    required String username,
    required String password,
  }) async {
    return await remoteDataSource.signInUser(
      username: username,
      password: password,
    );
  }

  Future<Map<String, dynamic>> getAdvisorById(int advisorId) {
    final token = _session.getToken();
    return remoteDataSource.getAdvisorById(token, advisorId);
  }
}