import 'package:agrocuy/infrastructure/services/session_service.dart'; // Assuming this path for your SessionService
import '../../data/datasources/advisor_remote_data_source.dart';
import '../../data/models/advisor_model.dart'; // Import the AdvisorModel


class AdvisorRepository {
  final AdvisorRemoteDataSource remoteDataSource;

  final SessionService _session = SessionService();

  AdvisorRepository(this.remoteDataSource);

  Future<List<AdvisorModel>> getAll() async {
    final token = _session.getToken();
    return remoteDataSource.getAdvisors(token);
  }

  Future<AdvisorModel> getById(String id) async {
    final token = _session.getToken();
    return remoteDataSource.getAdvisorById(id, token);
  }

  Future<void> create(AdvisorModel advisor) async {
    final token = _session.getToken();
    return remoteDataSource.createAdvisor(advisor, token);
  }

  Future<void> update(String id, AdvisorModel advisor) async {
    final token = _session.getToken();
    return remoteDataSource.updateAdvisor(id, advisor.toJson(), token);
  }

  Future<void> delete(String id) async {
    final token = _session.getToken();
    return remoteDataSource.deleteAdvisor(id, token);
  }
}