import 'package:agrocuy/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  Future<Map<String, dynamic>> getUserData(String token, int userId) async {
    return await remoteDataSource.getUserData(token, userId);
  }

  Future<Map<String, dynamic>> getProfileByRole(String token, String role) async {
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
}